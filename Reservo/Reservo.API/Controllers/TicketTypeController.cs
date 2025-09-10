using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.TicketType;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    public class TicketTypeController : BaseController<TicketType, TicketTypeGetDTO, TicketTypeInsertDTO, TicketTypeUpdateDTO, TicketTypeSearchObject>
    {
        public TicketTypeController(ITicketTypeService service, ILogger<BaseController<TicketType, TicketTypeGetDTO, TicketTypeInsertDTO, TicketTypeUpdateDTO, TicketTypeSearchObject>> logger) : base(service, logger)
        {
        }

        [HttpGet("Get/{eventId}")]
        public async Task<List<TicketTypeGetDTO>> GetTicketTypesByEvent(int eventId)
        {
            return await (_service as ITicketTypeService).GetTicketTypesByEvent(eventId);
        }
    }
}
