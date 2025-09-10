using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.StateMachineServices.EventStateMachine
{
    public class ActiveEventState : BaseEventState
    {
        public ActiveEventState(ReservoContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public async override Task<EventGetDTO> Cancel(Event entity)
        {
            entity.State = "cancelled";

            await _context.SaveChangesAsync();

            return _mapper.Map<EventGetDTO>(entity);
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
