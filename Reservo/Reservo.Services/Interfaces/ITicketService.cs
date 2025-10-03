using Reservo.Model.DTOs.TicketValidation;


namespace Reservo.Services.Interfaces
{
    public interface ITicketService
    {
        Task<TicketValidationResponseDTO> ValidateTicket(TicketValidationRequestDTO request);
        Task<bool> UseTicket(int ticketId);
    }
}
