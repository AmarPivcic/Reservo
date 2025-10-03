using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.City;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;
using Reservo.Services.Services;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class CityController : BaseController<City, CityGetDTO, CityInsertDTO, CityUpdateDTO, CitySearchObject>
    {
        public CityController(ICityService service, ILogger<BaseController<City, CityGetDTO, CityInsertDTO, CityUpdateDTO, CitySearchObject>> logger) : base(service, logger)
        {
        }

        [HttpGet("GetAllCities")]
        public async Task<PagedResult<CityGetDTO>> GetAllCities()
        {
            return await (_service as ICityService).GetAllCities();
        }

        [HttpDelete("DeleteCity/{id}")]
        public async Task<IActionResult> DeleteCity(int id)
        {
            var result = await (_service as ICityService).Delete(id);

            if (result != "OK")
                return BadRequest(result);

            return Ok();
        }
    }
}
