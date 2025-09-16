using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Venue;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class VenueService : BaseService<Venue, VenueGetDTO, VenueInsertDTO, VenueUpdateDTO, VenueSearchObject>, IVenueService
    {
        public VenueService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Venue> AddFilter(IQueryable<Venue> query, VenueSearchObject? search = null)
        {
            if (search == null)
                return query;

            if (search.CityId.HasValue)
                query = query.Where(v => v.CityId == search.CityId);
            if (search.CategoryId.HasValue)
                query = query.Where(v => v.AllowedCategories.Any(vc => vc.CategoryId == search.CategoryId));

            return query.OrderBy(v => v.Name);
        }
    }
}
