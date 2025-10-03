using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.TicketValidation;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class TicketService : ITicketService
    {
        private readonly ReservoContext _context;

        public TicketService(ReservoContext context)
        {
            _context = context;
        }
        public async Task<bool> UseTicket(int ticketId)
        {
            var ticket = await _context.Tickets.FindAsync(ticketId);
            if (ticket == null) return false;

            ticket.State = "Used";
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<TicketValidationResponseDTO> ValidateTicket(TicketValidationRequestDTO request)
        {
            var ticket = await _context.Tickets
               .Include(t => t.OrderDetail)
               .ThenInclude(od => od.TicketType)
               .FirstOrDefaultAsync(t => t.QRCode == request.QrCode);

            if (ticket == null)
            {
                return new TicketValidationResponseDTO
                {
                    IsValid = false,
                    Message = "Ticket not found"
                };
            }

            if (ticket.OrderDetail.TicketType.EventId != request.EventId)
            {
                return new TicketValidationResponseDTO
                {
                    IsValid = false,
                    Message = "Ticket does not belong to this event"
                };
            }

            if (ticket.State == "Used")
            {
                return new TicketValidationResponseDTO
                {
                    IsValid = false,
                    Message = "Ticket already used"
                };
            }

            return new TicketValidationResponseDTO
            {
                IsValid = true,
                TicketId = ticket.Id,
                Message = "Ticket is valid"
            };
        }
    }
}
