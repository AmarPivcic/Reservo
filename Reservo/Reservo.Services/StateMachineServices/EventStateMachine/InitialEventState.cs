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
    public class InitialEventState : BaseEventState
    {
        public InitialEventState(ReservoContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public override async Task<EventGetDTO> Insert(EventInsertDTO request)
        {
            var set = _context.Set<Event>();

            var entity = _mapper.Map<Event>(request);

            entity.State = "draft";

            set.Add(entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<EventGetDTO>(entity);
        }

        public override async Task<List<string>> AllowedActions()
        {
            var list = await base.AllowedActions();

            list.Add("Insert");

            return list;
        }
    }
}
