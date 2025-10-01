using MassTransit;
using Microsoft.Extensions.Logging;
using ReservationEmailConsumer.Contracts;
using ReservationEmailConsumer.Services;
namespace ReservationEmailConsumer.Consumers;

public class ReservationEmailConsumer : IConsumer<ReservationEmailMessage>
{
    private readonly IEmailSender _emailSender;
    private readonly ILogger<ReservationEmailConsumer> _logger;

    public ReservationEmailConsumer(IEmailSender emailSender, ILogger<ReservationEmailConsumer> logger)
    {
        _emailSender = emailSender;
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<ReservationEmailMessage> context)
    {

        var msg = context.Message;
        _logger.LogInformation("Received ReservationEmailMessage: ReservationId={ReservationId}, Email={Email}",
            msg.ReservationId, msg.UserEmail);

        try
        {
            await _emailSender.SendEmailAsync(msg.UserEmail, msg.Subject, msg.BodyHtml);
            _logger.LogInformation("Email sent to {Email} for reservation {ReservationId}", msg.UserEmail, msg.ReservationId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send email to {Email} for reservation {ReservationId}", msg.UserEmail, msg.ReservationId);
            throw;
        }
    }
}
