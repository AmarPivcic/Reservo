using AutoMapper;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
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
    }
}
