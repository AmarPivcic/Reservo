using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.StateMachineServices.EventStateMachine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class EventService : BaseService<Event, EventGetDTO, EventInsertDTO, EventUpdateDTO, EventSearchObject>, IEventService
    {
        public BaseEventState _baseEventState { get; set; }
        public EventService(ReservoContext context, IMapper mapper, BaseEventState baseEventState) : base(context, mapper)
        {
            _baseEventState = baseEventState;
        }

        public override async Task<EventGetDTO> Insert(EventInsertDTO request)
        {
            var state = _baseEventState.CreateState("initial");

            return await state.Insert(request);
        }

        public async Task<EventGetDTO> Activate(int id)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);

            if(entity != null)
            {
                var state = _baseEventState.CreateState(entity.State);

                return await state.Activate(entity.Id);
            }
            else
            {
                throw new UserException($"Entity ({id}) doesn't exists!");
            }
        }

        public override async Task<EventGetDTO> Update(int id, EventUpdateDTO request)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                var state = _baseEventState.CreateState(entity.State);

                return await state.Update(entity.Id, request);
            }
            else
            {
                throw new UserException($"Entity ({id}) doesn't exists!");
            }
        }

        public async Task<EventGetDTO> Draft(int id)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                var state = _baseEventState.CreateState(entity.State);

                return await state.Draft(id);
            }
            else
            {
                throw new UserException($"Entity ({id}) doesn't exists!");
            }
        }

        public async Task<EventGetDTO> Cancel(int id)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                var state = _baseEventState.CreateState(entity.State);

                return await state.Cancel(id);
            }
            else
            {
                throw new UserException($"Entity ({id}) doesn't exists!");
            }
        }

        public async Task<List<string>> AllowedActions(int id)
        {
            var entity = await _context.Events.FindAsync(id);
            var state = _baseEventState.CreateState(entity?.State ?? "initial");
            return await state.AllowedActions();
        }

        public async Task CompleteExpiredEventsAsync()
        {
            var now = DateTime.Now;

            var expiredEvents = _context.Events
                .Where(e => e.State == "active" && e.EndDate < now)
                .ToList();

            if (!expiredEvents.Any())
                return;

            foreach (var e in expiredEvents)
                e.State = "completed";

            var expiredEventIds = expiredEvents.Select(e => e.Id).ToList();

            var ordersToComplete = _context.Orders
               .Include(o => o.OrderDetails)
                   .ThenInclude(od => od.TicketType)
               .Where(o => o.State == "active" &&
                           o.OrderDetails.Any(od => expiredEventIds.Contains(od.TicketType.EventId)))
               .ToList();

            foreach (var order in ordersToComplete)
                order.State = "completed";

            if (expiredEvents.Count > 0)
                await _context.SaveChangesAsync();

            return;
        }

        public override IQueryable<Event> AddFilter(IQueryable<Event> query, EventSearchObject? search = null)
        {
            if (search == null)
                return query;

            if (search.OrganizerId.HasValue)
                query = query.Where(e => e.OrganizerId == search.OrganizerId);
            
            if (search.CategoryId.HasValue)
                query = query.Where(e => e.CategoryId == search.CategoryId);

            if (!string.IsNullOrWhiteSpace(search.State))
                query = query.Where(e => e.State == search.State);
            else
                query = query.Where(e => e.State == "active");

            if (!string.IsNullOrWhiteSpace(search.City))
                query = query.Where(e => e.Venue.City.Name.Contains(search.City));

            if (!string.IsNullOrWhiteSpace(search.Venue))
                query = query.Where(e => e.Venue.Name.Contains(search.Venue));

            if (search.Date.HasValue)
            {
                var date = search.Date.Value.Date;
                query = query.Where(e =>
                    (e.StartDate.Date <= date && e.EndDate.Date >= date)
                );
            }

            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(e => e.Name.Contains(search.Name));

            return query.OrderBy(e => e.StartDate);
        }

        public override IQueryable<Event> AddInclude(IQueryable<Event> query, EventSearchObject? search = null)
        {
            query = query.Include(e => e.Venue).ThenInclude(v => v.City);
            query = query.Include(e => e.TicketTypes);

            return query;
        }
    }
}
