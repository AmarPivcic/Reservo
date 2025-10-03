using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.TicketValidation;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class TicketController : ControllerBase
    {
        private readonly ITicketService _ticketService;

        public TicketController(ITicketService ticketService)
        {
            _ticketService = ticketService;
        }

        [HttpPost("Validate")]
        public async Task<ActionResult<TicketValidationResponseDTO>> ValidateTicket([FromBody] TicketValidationRequestDTO request)
        {
            var result = await _ticketService.ValidateTicket(request);
            return Ok(result);
        }

        [HttpPost("Use/{ticketId}")]
        public async Task<IActionResult> UseTicket(int ticketId)
            {
                var success = await _ticketService.UseTicket(ticketId);
                if (!success) return NotFound(new { message = "Ticket not found" });

                return Ok(new { message = "Ticket marked as used" });
            }
    }
}
