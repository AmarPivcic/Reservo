using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;
using System.Security.Claims;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class EventController : BaseController<Event, EventGetDTO, EventInsertDTO, EventUpdateDTO, EventSearchObject>
    {

        public EventController(IEventService service, ILogger<BaseController<Event, EventGetDTO, EventInsertDTO,EventUpdateDTO,EventSearchObject>> logger) : base(service, logger)
        {
        }

        [HttpGet("GetByToken")]
        public async Task<PagedResult<EventGetDTO>> GetByToken([FromQuery] EventSearchObject? search = null)
        {
            search ??= new EventSearchObject();

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                search.OrganizerId = userId;
            }

            return await (_service as IEventService).Get(search);
        }

        [HttpPost("Insert")]
        public async Task<EventGetDTO> Insert([FromBody] EventInsertDTO request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
                request.OrganizerId = userId;

            return await (_service as IEventService).Insert(request);
        }

        [HttpPatch("{id}/Draft")]
        public async Task<ActionResult<EventGetDTO>> Draft(int id)
        {
            try
            {
                var updated = await (_service as IEventService).Draft(id);
                return Ok(updated);
            }
            catch (UserException ex)
            {

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPatch("{id}/Activate")]
        public async Task<ActionResult<EventGetDTO>> Activate(int id)
        {
            try
            {
                var updated = await (_service as IEventService).Activate(id);
                return Ok(updated);
            }
            catch (UserException ex)
            {

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPatch("{id}/Cancel")]
        public async Task<ActionResult<EventGetDTO>> Cancel(int id)
        {
            try
            {
                var updated = await (_service as IEventService).Cancel(id);
                return Ok(updated);
            }
            catch (UserException ex)
            {

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPatch("{id}/Complete")]
        public async Task<ActionResult<EventGetDTO>> Complete(int id)
        {
            try
            {
                var updated = await (_service as IEventService).Complete(id);
                return Ok(updated);
            }
            catch (UserException ex)
            {

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete]
        public async Task<ActionResult<string>> Delete(int id)
        {
            try
            {
                await (_service as IEventService).Delete(id);
                return Ok("Event deleted");
            }
            catch (UserException ex)
            {

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("{id}/AllowedActions")]
        public async Task<List<string>> AllowedActions(int id)
        {
            return await (_service as IEventService).AllowedActions(id);
        }
    }
}
