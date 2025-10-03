using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Venue;
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
    public class VenueService : BaseService<Venue, VenueGetDTO, VenueInsertDTO, VenueUpdateDTO, VenueSearchObject>, IVenueService
    {
        public VenueService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public async Task<PagedResult<VenueGetDTO>> GetAllVenues()
        {
            var list = await _context.Venues
                .Include(v => v.AllowedCategories)   
                    .ThenInclude(vc => vc.Category)        
                .Include(v => v.City)                       
                .ToListAsync();
            var mapped = _mapper.Map<List<VenueGetDTO>>(list);

            return new PagedResult<VenueGetDTO>
            {
                Count = mapped.Count,
                Result = mapped
            };
        }

        public override async Task<VenueGetDTO> Insert(VenueInsertDTO request)
        {
            var venue = _mapper.Map<Venue>(request);

            venue.AllowedCategories = request.CategoryIds
                .Select(catId => new VenueCategory { CategoryId = catId })
                .ToList();

            _context.Venues.Add(venue);
            await _context.SaveChangesAsync();

            return _mapper.Map<VenueGetDTO>(venue);
        }

        public override async Task<VenueGetDTO> Update(int id, VenueUpdateDTO request)
        {
            var venue = await _context.Venues
        .Include(v => v.AllowedCategories)
        .FirstOrDefaultAsync(v => v.Id == id);

            if (venue == null)
                throw new UserException("Venue does not exist");

            _mapper.Map(request, venue);

            var toRemove = venue.AllowedCategories
                .Where(vc => !request.CategoryIds.Contains(vc.CategoryId))
                .ToList();

            foreach (var vc in toRemove)
            {
                venue.AllowedCategories.Remove(vc);
            }

            var existingIds = venue.AllowedCategories.Select(vc => vc.CategoryId).ToHashSet();
            var toAdd = request.CategoryIds.Where(cid => !existingIds.Contains(cid));
            foreach (var catId in toAdd)
            {
                venue.AllowedCategories.Add(new VenueCategory { CategoryId = catId });
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<VenueGetDTO>(venue);
        }

        public override async Task<string> Delete(int id)
        {
            var venue = await _context.Venues
                .Include(v => v.AllowedCategories)
                .Include(v => v.Events)            
                .FirstOrDefaultAsync(v => v.Id == id);

            if (venue == null)
                return "Venue not found.";

            if (venue.Events.Any())
                return "Cannot delete venue: it has events scheduled.";

            _context.Venues.Remove(venue);
            await _context.SaveChangesAsync();

            return "OK";
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
