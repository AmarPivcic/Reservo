using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.TicketType;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class TicketTypeController : BaseController<TicketType, TicketTypeGetDTO, TicketTypeInsertDTO, TicketTypeUpdateDTO, TicketTypeSearchObject>
    {
        public TicketTypeController(ITicketTypeService service, ILogger<BaseController<TicketType, TicketTypeGetDTO, TicketTypeInsertDTO, TicketTypeUpdateDTO, TicketTypeSearchObject>> logger) : base(service, logger)
        {
        }

        [HttpGet("GetByEvent/{eventId}")]
        public async Task<List<TicketTypeGetDTO>> GetTicketTypesByEvent(int eventId)
        {
            return await (_service as ITicketTypeService).GetTicketTypesByEvent(eventId);
        }

        [HttpGet("Get/{Id}")]
        public async Task<TicketTypeGetDTO> GetTicketTypesId(int Id)
        {
            return await (_service as ITicketTypeService).GetTicketTypeById(Id);
        }
    }
}
