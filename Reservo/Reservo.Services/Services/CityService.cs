using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.City;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class CityService : BaseService<City, CityGetDTO, CityInsertDTO, CityUpdateDTO, CitySearchObject>, ICityService
    {
        public CityService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<CityGetDTO>> Get(CitySearchObject? search = null)
        {
            var query = _context.Cities
                .Where(c => c.Venues.Any());

            var list = await query.ToListAsync();
            var mapped = _mapper.Map<List<CityGetDTO>>(list);

            return new PagedResult<CityGetDTO>
            {
                Count = mapped.Count,
                Result = mapped
            };
        }

        public async Task<PagedResult<CityGetDTO>> GetAllCities()
        {
            var list = await _context.Cities.ToListAsync();
            var mapped = _mapper.Map<List<CityGetDTO>>(list);

            return new PagedResult<CityGetDTO>
            {
                Count = mapped.Count,
                Result = mapped
            };
        }

        public override async Task<string> Delete(int id)
        {
            var city = await _context.Cities
            .Include(c => c.Venues)
            .Include(c => c.Users)
            .FirstOrDefaultAsync(c => c.Id == id);

            if (city == null)
                return "City not found.";

            if (city.Venues.Any())
                return "Cannot delete city: it has related venues.";

            if (city.Users.Any())
                return "Cannot delete city: it has related users.";

            _context.Cities.Remove(city);
            await _context.SaveChangesAsync();

            return "OK";
        }
    }
}
