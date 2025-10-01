using DotNetEnv;
using MassTransit;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using ReservationEmailConsumer.Consumers;
using ReservationEmailConsumer.Services;


Env.Load(@"../.env");

var builder = Host.CreateDefaultBuilder(args)
    .ConfigureServices((context, services) =>
    {

        services.Configure<SmtpSettings>(options =>
        {
            options.Host = Environment.GetEnvironmentVariable("SMTP_HOST") ?? "smtp.gmail.com";
            options.Port = int.TryParse(Environment.GetEnvironmentVariable("SMTP_PORT"), out var port) ? port : 587;
            options.Username = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "";
            options.Password = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "";
            options.UseSsl = bool.TryParse(Environment.GetEnvironmentVariable("SMTP_USESSL"), out var useSsl) ? useSsl : true;
            options.FromName = Environment.GetEnvironmentVariable("SMTP_FROMNAME") ?? "Reservo";
            options.FromEmail = Environment.GetEnvironmentVariable("SMTP_FROMEMAIL") ?? "noreply@reservo.local";
        });

        services.AddTransient<IEmailSender, SmtpEmailSender>();

        services.AddMassTransit(x =>
        {
            x.AddConsumer<ReservationEmailConsumer.Consumers.ReservationEmailConsumer>();

            x.UsingRabbitMq((ctx, cfg) =>
            {
                var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var user = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var pass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var queueName = Environment.GetEnvironmentVariable("RABBITMQ_QUEUE") ?? "reservation-email-queue";

                cfg.Host(host, "/", h =>
                {
                    h.Username(user);
                    h.Password(pass);
                });

                cfg.ReceiveEndpoint(queueName, e =>
                {
                    e.UseMessageRetry(r => r.Interval(3, TimeSpan.FromSeconds(5)));
                    e.ConfigureConsumer<ReservationEmailConsumer.Consumers.ReservationEmailConsumer>(ctx);
                });
            });
        });

        services.AddMassTransitHostedService();
    });

var host = builder.Build();
await host.RunAsync();
