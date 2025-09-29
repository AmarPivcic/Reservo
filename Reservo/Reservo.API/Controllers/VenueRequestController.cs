using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.VenueRequest;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Interfaces;
using System.Security.Claims;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class VenueRequestController : BaseController<VenueRequest, VenueRequestGetDTO, VenueRequestInsertDTO, VenueRequestUpdateDTO, VenueRequestSearchObject>
    {
        public VenueRequestController(IVenueRequestService service, ILogger<BaseController<VenueRequest, VenueRequestGetDTO, VenueRequestInsertDTO, VenueRequestUpdateDTO, VenueRequestSearchObject>> logger) : base(service, logger)
        {
        }

        [HttpPost]
        public override async Task<VenueRequestGetDTO> Insert([FromBody] VenueRequestInsertDTO request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                request.OrganizerId = userId;
            }
            return await (_service as IVenueRequestService).Insert(request);
        }
    }
}
