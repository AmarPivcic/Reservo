namespace Reservo.Contracts
{
    public record ReservationEmailMessage
    {
        public int ReservationId { get; init; }
        public string UserEmail { get; init; } = string.Empty;
        public string UserName { get; init; } = string.Empty;
        public string Subject { get; init; } = string.Empty;
        public string BodyHtml { get; init; } = string.Empty;
        public DateTime? ScheduledAt { get; init; }
    }
}
