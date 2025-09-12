using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.StateMachineServices.EventStateMachine
{
    public class DraftEventState : BaseEventState
    {
        public DraftEventState(ReservoContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public async override Task<EventGetDTO> Activate(int id)
        {
            var entity = _context.Events.FirstOrDefault(e => e.Id == id);

            if (entity != null)
            {
                entity.State = "active";

                await _context.SaveChangesAsync();

                return _mapper.Map<EventGetDTO>(entity);
            }
            else
            {
                throw new UserException("Event not found!");
            }
        }

        public override async Task<EventGetDTO> Update(int id, EventUpdateDTO request)
        {
            var entity = _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .Include(e => e.User)
                .FirstOrDefault(e => e.Id == id);

            if (entity == null)
                throw new UserException("Event not found!");

            _mapper.Map(request, entity);

            entity.TicketTypes.Clear();
            foreach (var ticketTypeDto in request.TicketTypes)
            {
                var ticketType = _mapper.Map<TicketType>(ticketTypeDto);
                ticketType.Event = entity;

                entity.TicketTypes.Add(ticketType);
            }


            await _context.SaveChangesAsync();

            var updatedEntity = _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .Include(e => e.User)
                .FirstOrDefault(e => e.Id == id);

            return _mapper.Map<EventGetDTO>(entity);
        }

        public override async Task<EventGetDTO> Draft(int id)
        {
            var entity = _context.Events.FirstOrDefault(e => e.Id == id);

            if (entity != null)
            {
                entity.State = "draft";

                await _context.SaveChangesAsync();
            }
            else
            {
                throw new UserException("Event not found!");
            }

            var updatedEntity = _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .Include(e => e.User)
                .FirstOrDefault(e => e.Id == id);

            return _mapper.Map<EventGetDTO>(updatedEntity);
        }
    }
}
