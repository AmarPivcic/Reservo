using MailKit.Net.Smtp;
using Microsoft.Extensions.Options;
using MimeKit;

namespace ReservationEmailConsumer.Services;

public class SmtpSettings
{
    public string Host { get; set; } = "localhost";
    public int Port { get; set; } = 25;
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public bool UseSsl { get; set; } = false;
    public string FromName { get; set; } = "Reservo";
    public string FromEmail { get; set; } = "noreply@reservo.local";
}

public class SmtpEmailSender : IEmailSender
{
    private readonly SmtpSettings _settings;

    public SmtpEmailSender(IOptions<SmtpSettings> settings)
    {
        _settings = settings.Value;
    }

    public async Task SendEmailAsync(string toEmail, string subject, string bodyHtml)
    {
        var msg = new MimeMessage();
        msg.From.Add(new MailboxAddress(_settings.FromName, _settings.FromEmail));
        msg.To.Add(MailboxAddress.Parse(toEmail));
        msg.Subject = subject;

        var bodyBuilder = new BodyBuilder { HtmlBody = bodyHtml };
        msg.Body = bodyBuilder.ToMessageBody();

        using var client = new SmtpClient();

        await client.ConnectAsync(_settings.Host, _settings.Port, false);

        if (!string.IsNullOrWhiteSpace(_settings.Username))
        {
            await client.AuthenticateAsync(_settings.Username, _settings.Password);
        }

        await client.SendAsync(msg);
        await client.DisconnectAsync(true);
    }
}
