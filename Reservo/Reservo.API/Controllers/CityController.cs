using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.City;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class CityController : BaseController<City, CityGetDTO, CityInsertDTO, CityUpdateDTO, CitySearchObject>
    {
        public CityController(ICityService service, ILogger<BaseController<City, CityGetDTO, CityInsertDTO, CityUpdateDTO, CitySearchObject>> logger) : base(service, logger)
        {
        }
    }
}
