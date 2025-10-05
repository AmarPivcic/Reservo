using AutoMapper;
using DotNetEnv;
using MassTransit;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Reservo.API.HostedServices;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.Mapping;
using Reservo.Services.Services;
using Reservo.Services.StateMachineServices.EventStateMachine;
using Stripe;
using System.Text;
using ReservationEmailConsumer.Services;
using Microsoft.OpenApi.Models;

Env.Load(@"../.env");

var builder = WebApplication.CreateBuilder(args);

// ---- ENV VARIABLES ----
var jwtSecretFromEnv = Environment.GetEnvironmentVariable("JWT_SECRET_KEY");
var stripeSecretFromEnv = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");
var rabbitMqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST");
var rabbitMqUsername = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME");
var rabbitMqPassword = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD");
var smtpHost = Environment.GetEnvironmentVariable("SMTP_HOST");
var smtpUsername = Environment.GetEnvironmentVariable("SMTP_USERNAME");
var smtpPassword = Environment.GetEnvironmentVariable("SMTP_PASSWORD");
var smtpPort = Environment.GetEnvironmentVariable("SMTP_PORT");
var smtpUseSsl = Environment.GetEnvironmentVariable("SMTP_USESSL");
var smtpFromName = Environment.GetEnvironmentVariable("SMTP_FROMNAME");
var smtpFromEmail = Environment.GetEnvironmentVariable("SMTP_FROMEMAIL");

if (string.IsNullOrEmpty(stripeSecretFromEnv))
    throw new Exception("Stripe secret key not found in environment variables.");

// ---- DEPENDENCY INJECTION ----
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IEventService, Reservo.Services.Services.EventService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IVenueService, VenueService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<ITicketTypeService, TicketTypeService>();
builder.Services.AddTransient<IOrderService, OrderService>();
builder.Services.AddTransient<IStripeService, StripeService>();
builder.Services.AddTransient<IReviewService, Reservo.Services.Services.ReviewService>();
builder.Services.AddTransient<IVenueRequestService, VenueRequestService>();
builder.Services.AddScoped<IEventVectorService, EventVectorService>();
builder.Services.AddScoped<RecommendationService>();
builder.Services.AddScoped<IEventVectorizerService, EventVectorizerService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<ITicketService, TicketService>();

builder.Services.AddTransient<BaseEventState>();
builder.Services.AddTransient<InitialEventState>();
builder.Services.AddTransient<DraftEventState>();
builder.Services.AddTransient<ActiveEventState>();
builder.Services.AddTransient<CancelledEventState>();
builder.Services.AddTransient<CompletedEventState>();

// ---- RABBITMQ ----
builder.Services.AddMassTransit(x =>
{
    x.UsingRabbitMq((context, cfg) =>
    {
        cfg.Host(rabbitMqHost, "/", h =>
        {
            h.Username(rabbitMqUsername);
            h.Password(rabbitMqPassword);
        });
    });
});

// ---- SMTP ----
builder.Services.Configure<SmtpSettings>(options =>
{
    options.Host = smtpHost ?? "smtp.gmail.com";
    options.Port = int.TryParse(smtpPort, out var port) ? port : 587;
    options.Username = smtpUsername ?? "";
    options.Password = smtpPassword ?? "";
    options.UseSsl = bool.TryParse(smtpUseSsl, out var useSsl) ? useSsl : true;
    options.FromName = smtpFromName ?? "Reservo";
    options.FromEmail = smtpFromEmail ?? "noreply@reservo.local";
});

// ---- MAPPING & CONTROLLERS ----
builder.Services.AddAutoMapper(typeof(UserProfile).Assembly);
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// ---- SWAGGER ----
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Reservo API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: 'Bearer {token}'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// ---- DATABASE ----
var connectionString = builder.Configuration.GetConnectionString("ReservoConnection");
builder.Services.AddDbContext<ReservoContext>(options =>
    options.UseSqlServer(connectionString, sqlOptions => sqlOptions.MigrationsAssembly("Reservo.API"))
);

// ---- JWT ----
var jwtSecretKey = !string.IsNullOrEmpty(jwtSecretFromEnv)
    ? jwtSecretFromEnv
    : builder.Configuration.GetValue<string>("JwtSettings:Secret");

var keyBytes = Encoding.ASCII.GetBytes(jwtSecretKey);
builder.Services.AddTransient<IAuthService, AuthService>(provider =>
{
    var context = provider.GetRequiredService<ReservoContext>();
    var mapper = provider.GetRequiredService<IMapper>();
    return new AuthService(jwtSecretKey, context, mapper);
});

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(keyBytes),
        ValidateIssuer = false,
        ValidateAudience = false
    };
});

StripeConfiguration.ApiKey = stripeSecretFromEnv;

// ---- HOSTED SERVICE ----
builder.Services.AddHostedService<EventStateUpdater>();

var app = builder.Build();

// ---- DATABASE MIGRATION + SEEDING ----
try
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<ReservoContext>();
    var env = scope.ServiceProvider.GetRequiredService<IWebHostEnvironment>();

    Console.WriteLine("Applying EF Core migrations (if any)...");
    try
    {
        await context.Database.MigrateAsync();
    }
    catch (SqlException ex) when (ex.Number == 1801)
    {
        Console.WriteLine("Database already exists. Continuing without creating.");
    }

    if (!await context.Roles.AnyAsync())
    {
        Console.WriteLine("Database is empty. Running seeder...");
        var seeder = new Reservo.API.Controllers.DataSeedController(context);
        await seeder.Seed();
        Console.WriteLine("Seeding complete.");
    }
    else
    {
        Console.WriteLine("Database already contains data. Skipping seeding.");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Startup DB step failed (non-fatal): {ex.Message}");
}

using var startupScope = app.Services.CreateScope();
var vectorizerService = startupScope.ServiceProvider.GetRequiredService<IEventVectorizerService>();
await vectorizerService.TrainAndStoreEventVectors();
// ---- PIPELINE ----
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
