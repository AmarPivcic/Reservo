using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Event;
using Reservo.Model.DTOs.OrderDetail;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;
using Reservo.Services.Services;
using System.Security.Claims;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class EventController : BaseController<Event, EventGetDTO, EventInsertDTO, EventUpdateDTO, EventSearchObject>
    {
        private readonly RecommendationService _recommendationService;
        private readonly IEventVectorizerService _vectorizerService;

        public EventController(IEventService service, RecommendationService recommendationService, IEventVectorizerService vectorizerService, ILogger<BaseController<Event, EventGetDTO, EventInsertDTO,EventUpdateDTO,EventSearchObject>> logger) : base(service, logger)
        {
            _vectorizerService = vectorizerService;
            _recommendationService = recommendationService;
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

        [HttpGet("GetEventsForStats")]
        public async Task<PagedResult<EventGetDTO>> GetEventsForStats([FromQuery] EventSearchObject? search = null)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                int organizerId = userId;
                return await (_service as IEventService).GetEventsForStats(organizerId);
            }
            return await (_service as IEventService).Get();
        }

        [HttpGet("GetOrdersForEvents/{eventId}")]
        public async Task<List<OrderDetailsDTO>> GetOrdersForEvents(int eventId)
        {

            return await (_service as IEventService).GetOrdersForEventAsync(eventId);

        }

        [HttpPost("TrainEventVectors")]
        public async Task<IActionResult> TrainEventVectors()
        {
            await _vectorizerService.TrainAndStoreEventVectors();
            return Ok("Event vectors trained and stored successfully");
        }

        [HttpGet("GetRecommended")]
        public async Task<IActionResult> GetRecommendations(int topN = 5)
        {
            int userid;
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                userid = userId;
                var recommendations = await _recommendationService.GetRecommendedEvents(userid, topN);
                return Ok(recommendations);
            }
            return BadRequest(new { message = "User not found!" });
        }


        [HttpPost("UpdateProfile/{eventId}")]
        public async Task<IActionResult> UpdateProfile(int eventId)
        {
            var evVector = await _recommendationService.GetEventVector(eventId);
            if (evVector == null || evVector.Vector.Length == 0)
                return NotFound("Event vector not found");

            int userid;
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                userid = userId;
                await _recommendationService.UpdateUserProfile(userId, evVector.Vector);
                return Ok();
            }
            return BadRequest(new { message = "Error updating profile"});
        }

        [HttpGet("GetByRating")]
        public async Task<ActionResult<List<EventGetDTO>>> GetByRating()
        {
            try
            {
                var result = await (_service as IEventService).GetByRating();
                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
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
