using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Review;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;
using System.Security.Claims;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class ReviewController : BaseController<Review, ReviewGetDTO, ReviewInsertDTO, ReviewUpdateDTO, ReviewSearchObject>
    {
        public ReviewController(IReviewService service, ILogger<BaseController<Review, ReviewGetDTO, ReviewInsertDTO, ReviewUpdateDTO, ReviewSearchObject>> logger) : base(service, logger)
        {
        }

        [HttpPost("InsertReview")]
        public async Task<IActionResult> Insert([FromBody] ReviewInsertDTO request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                request.UserId = userId;
            }
            try
            {
                var result = await (_service as IReviewService).Insert(request);
                return Ok(result);
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("EventReviews/{eventId}")]
        public async Task<IActionResult> GetByEventId(int eventId)
        {
            try
            {
                var reviews = await (_service as IReviewService).GetByEventId(eventId);
                return Ok(reviews);
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("OrderReview/{orderId}")]
        public async Task<IActionResult> GetByOrderId(int orderId)
        {
            try
            {
                int UserId;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
                {
                    UserId = userId;
                    var reviews = await (_service as IReviewService).GetByOrderId(orderId, UserId);
                    return Ok(reviews);
                }
                return BadRequest(new { message = "User not found!" });
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
