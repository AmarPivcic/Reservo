using AutoMapper;
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

                return await state.Activate(entity);
            }
            else
            {
                throw new UserException($"Entity ({id}) doesn't exists!");
            }
        }

        public async Task<EventGetDTO> Cancel(int id)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);
            
            if(entity != null)
            {
                var state = _baseEventState.CreateState(entity.State);

                return await state.Cancel(entity);
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
    }
}
