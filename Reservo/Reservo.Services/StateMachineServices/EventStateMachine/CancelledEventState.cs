using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.StateMachineServices.EventStateMachine
{
    public class CancelledEventState : BaseEventState
    {
        public CancelledEventState(ReservoContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }
        public override async Task<EventGetDTO> Draft(int id)
        {
            var entity = await _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                entity.State = "draft";

                await _context.SaveChangesAsync();
            }
            else
            {
                throw new UserException("Event not found!");
            }

            return _mapper.Map<EventGetDTO>(entity);
        }
    }
}
