using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.VenueRequest;
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
    public class VenueRequestService : BaseService<VenueRequest, VenueRequestGetDTO, VenueRequestInsertDTO, VenueRequestUpdateDTO, VenueRequestSearchObject>, IVenueRequestService
    {
        public VenueRequestService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<VenueRequestGetDTO> Insert(VenueRequestInsertDTO request)
        {
            var venueRequest = new VenueRequest
            {
                OrganizerId = (int)request.OrganizerId,
                VenueName = request.VenueName,
                CityName = request.CityName,
                Address = request.Address,
                Capacity = request.Capacity,
                Description = request.Description,
                State = "Pending",
                CreatedAt = DateTime.Now,
                SuggestedCategories = request.SuggestedCategories
            };

            venueRequest.VenueRequestCategories = request.AllowedCategoryIds
                .Select(id => new VenueRequestCategory
                {
                    CategoryId = id
                }).ToList();

            _context.VenueRequests.Add(venueRequest);
            await _context.SaveChangesAsync();

            var response = await _context.VenueRequests
                .Include(vr => vr.Organizer)
                .Include(vr => vr.VenueRequestCategories)
                .FirstOrDefaultAsync(vr => vr.Id == venueRequest.Id);

            return _mapper.Map<VenueRequestGetDTO>(response);
        }

        public override async Task<VenueRequestGetDTO> Update(int id, VenueRequestUpdateDTO request)
        {
            var venueRequest = await _context.VenueRequests
                .Include(v => v.VenueRequestCategories)
                .FirstOrDefaultAsync(v => v.Id == id);

            if (venueRequest == null)
                throw new Exception("VenueRequest not found");

            venueRequest.VenueName = request.VenueName;
            venueRequest.CityName = request.CityName;
            venueRequest.Address = request.Address;
            venueRequest.Capacity = request.Capacity;
            venueRequest.State = request.State;

            venueRequest.VenueRequestCategories.Clear();
            foreach (var categoryId in request.AllowedCategoryIds)
            {
                venueRequest.VenueRequestCategories.Add(new VenueRequestCategory
                {
                    VenueRequestId = venueRequest.Id,
                    CategoryId = categoryId
                });
            }

            await _context.SaveChangesAsync();

            if (request.State.Equals("Accepted", StringComparison.OrdinalIgnoreCase))
            {
                var city = await _context.Cities
                    .FirstOrDefaultAsync(c => c.Name.ToLower() == request.CityName.ToLower());

                if (city == null)
                {
                    city = new City { Name = request.CityName };
                    _context.Cities.Add(city);
                    await _context.SaveChangesAsync();
                }

                var newVenue = new Venue
                {
                    Name = request.VenueName,
                    Address = request.Address,
                    Capacity = request.Capacity,
                    Description = request.SuggestedCategories,
                    CityId = city.Id
                };


                foreach (var categoryId in request.AllowedCategoryIds)
                {
                    newVenue.AllowedCategories.Add(new VenueCategory
                    {
                        CategoryId = categoryId
                    });
                }

                _context.Venues.Add(newVenue);
                await _context.SaveChangesAsync();
            }

            var response = await _context.VenueRequests
               .Include(vr => vr.Organizer)
               .Include(vr => vr.VenueRequestCategories)
               .FirstOrDefaultAsync(vr => vr.Id == venueRequest.Id);

            return _mapper.Map<VenueRequestGetDTO>(response);
        }


        public override IQueryable<VenueRequest> AddFilter(IQueryable<VenueRequest> query, VenueRequestSearchObject? search = null)
        {
            if (search == null)
                return query;

            if (!string.IsNullOrWhiteSpace(search.State))
                query = query.Where(e => e.State == search.State);
            else
                query = query.Where(e => e.State == "Pending");

            return query.OrderBy(e => e.CreatedAt);
        }

        public override IQueryable<VenueRequest> AddInclude(IQueryable<VenueRequest> query, VenueRequestSearchObject? search = null)
        {
            query = query.Include(vr => vr.Organizer);
            query = query.Include(vr => vr.VenueRequestCategories);

            return query;
        }

    }
}
