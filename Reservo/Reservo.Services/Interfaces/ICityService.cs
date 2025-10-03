using Reservo.Model.DTOs.City;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface ICityService : IBaseService<City, CityGetDTO, CityInsertDTO, CityUpdateDTO, CitySearchObject>
    {
        Task<PagedResult<CityGetDTO>> GetAllCities();
    }
}
