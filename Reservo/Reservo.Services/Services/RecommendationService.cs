using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class RecommendationService
    {
        private readonly IEventVectorService _eventVectorService;
        private readonly IUserService _userService;
        private readonly ReservoContext _context;
        private readonly IMapper _mapper;

        public RecommendationService(ReservoContext context, IMapper mapper, IEventVectorService eventVectorService, IUserService userService)
        {
            _eventVectorService = eventVectorService;
            _userService = userService;
            _context = context;
            _mapper = mapper;
        }

        public async Task UpdateUserProfile(int userId, float[] eventVector)
        {
            var profile = await _userService.GetUserProfileVector(userId);

            if (profile == null)
                profile = eventVector;
            else
                profile = VectorOps.Average(profile, eventVector);

            await _userService.UpdateUserProfileVector(userId, profile);
        }

        public async Task<List<EventGetDTO>> GetRecommendedEvents(int userId, int topN = 5)
        {
            var userProfile = await _userService.GetUserProfileVector(userId);
            if (userProfile == null)
                return new List<EventGetDTO>();

            var allVectors = await _eventVectorService.GetAllWithEventAsync();

            var selectedEventIds = allVectors
                                    .Where(ev => ev.Vector != null && ev.Vector.Length > 0)
                                    .Select(ev => new
                                    {
                                        Event = ev.Event,
                                        Score = VectorOps.CosineSimilarity(userProfile, ev.Vector!)
                                    })
                                    .OrderByDescending(x => x.Score)
                                    .Take(topN)
                                    .Select(x => x.Event.Id)
                                    .ToList();

            var recommendedEvents = await _context.Events.Where(e => selectedEventIds.Contains(e.Id))
                .Include(e => e.Category)
                .Include(e => e.Venue)
                    .ThenInclude(v => v.City)
                .Include(e => e.User)
                .Include(e => e.TicketTypes)
                .Include(e => e.Reviews)
                .ToListAsync();

            var eventDtos = _mapper.Map<List<EventGetDTO>>(recommendedEvents);

            return eventDtos;

        }

        public async Task<EventVector> GetEventVector(int eventId)
        {
            return await _eventVectorService.GetByEventIdAsync(eventId);
        }
    }
}

