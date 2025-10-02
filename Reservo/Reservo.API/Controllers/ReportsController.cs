using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reservo.Services.Interfaces;
using System.Security.Claims;

namespace Reservo.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportsController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpGet("ProfitByCategory")]
        public async Task<IActionResult> GetProfitByCategory(int year, int? month = null)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                var result = await _reportService.GetProfitByCategoryAsync(userId, year, month);
                return Ok(result);
            }

            return BadRequest(new { message = "Error fetching profit by category" });
        }

        [HttpGet("ProfitByMonth")]
        public async Task<IActionResult> GetProfitByMonth(int year)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                var result = await _reportService.GetProfitByMonthAsync(userId, year);
                return Ok(result);
            }

            return BadRequest(new { message = "Error fetching profit by category" });
        }

        [HttpGet("ProfitByDay")]
        public async Task<IActionResult> GetProfitByDay(int year, int month)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                var result = await _reportService.GetProfitByDayAsync(userId, year, month);
                return Ok(result);
            }

            return BadRequest(new { message = "Error fetching profit by category" });
        }
    }

}
