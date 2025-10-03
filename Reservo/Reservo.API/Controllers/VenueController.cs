using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Venue;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class VenueController : BaseController<Venue, VenueGetDTO, VenueInsertDTO, VenueUpdateDTO, VenueSearchObject>
    {
        public VenueController(IVenueService service, ILogger<BaseController<Venue, VenueGetDTO, VenueInsertDTO, VenueUpdateDTO, VenueSearchObject>> logger) : base(service, logger)
        {
        }

        [HttpGet("GetAllVenues")]
        public async Task<PagedResult<VenueGetDTO>> GetAllVenues()
        {
            return await (_service as IVenueService).GetAllVenues();
        }

        [HttpDelete("DeleteVenue/{id}")]
        public async Task<IActionResult> DeleteCity(int id)
        {
            var result = await (_service as IVenueService).Delete(id);

            if (result != "OK")
                return BadRequest(result);

            return Ok();
        }
    }
}
