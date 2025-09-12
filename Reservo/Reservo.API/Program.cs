using AutoMapper;
using DotNetEnv;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.IdentityModel.Tokens;
using Reservo.API.HostedServices;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.Mapping;
using Reservo.Services.Services;
using Reservo.Services.StateMachineServices.EventStateMachine;
using System.Text;


Env.Load(@"../.env");

var builder = WebApplication.CreateBuilder(args);

var jwtSecretFromEnv = Environment.GetEnvironmentVariable("JWT_SECRET_KEY");

builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IEventService, EventService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IVenueService, VenueService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<ITicketTypeService, TicketTypeService>();


builder.Services.AddTransient<BaseEventState>();
builder.Services.AddTransient<InitialEventState>();
builder.Services.AddTransient<DraftEventState>();
builder.Services.AddTransient<ActiveEventState>();
builder.Services.AddTransient<CancelledEventState>();
builder.Services.AddTransient<CompletedEventState>();



builder.Services.AddAutoMapper(typeof(UserProfile).Assembly);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

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

builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: 'Bearer {token}'",
        Name = "Authorization",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

var connectionString = builder.Configuration.GetConnectionString("ReservoConnection");
builder.Services.AddDbContext<ReservoContext>(options =>
    options.UseSqlServer(connectionString, sqlOptions => sqlOptions.MigrationsAssembly("Reservo.API"))
    );

builder.Services.AddHostedService<EventStateUpdater>();

var app = builder.Build();

// Configure the HTTP request pipeline.
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
