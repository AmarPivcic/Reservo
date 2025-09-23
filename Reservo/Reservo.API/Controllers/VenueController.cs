using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Venue;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class VenueController : BaseController<Venue, VenueGetDTO, VenueInsertDTO, VenueUpdateDTO, VenueSearchObject>
    {
        public VenueController(IVenueService service, ILogger<BaseController<Venue, VenueGetDTO, VenueInsertDTO, VenueUpdateDTO, VenueSearchObject>> logger) : base(service, logger)
        {
        }
    }
}
