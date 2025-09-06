using AutoMapper;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.StateMachineServices.EventStateMachine
{
    public class BaseEventState
    {
        protected ReservoContext _context;
        protected IMapper _mapper;
        public IServiceProvider _serviceProvider;

        public BaseEventState(ReservoContext context, IMapper mapper, IServiceProvider serviceProvider)
        {
            _context = context;
            _mapper = mapper;
            _serviceProvider = serviceProvider;
        }

        public virtual async Task<EventGetDTO> Insert(EventInsertDTO request)
        {
            throw new UserException("Action not allowed.");
        }

        public virtual async Task<EventGetDTO> Update(EventUpdateDTO request)
        {
            throw new UserException("Action not allowed.");
        }

        public virtual async Task<EventGetDTO> Activate(int id)
        {
            throw new UserException("Action not allowed.");
        }

        public virtual async Task<string> Delete(Event entity)
        {
            throw new UserException("Action not allowed.");
        }

        public virtual async Task<EventGetDTO> Cancel(Event entity)
        {
            throw new UserException("Action not allowed.");
        }

        public virtual async Task<List<string>> AllowedActions()
        {
            return new List<string>();
        }

        public BaseEventState CreateState(string state)
        {
            switch(state)
            {
                case "initial":
                    case null:
                    return _serviceProvider.GetService<InitialEventState>();
                    break;
                case "draft":
                    return _serviceProvider.GetService<DraftEventState>();
                    break;
                case "active":
                    return _serviceProvider.GetService<ActiveEventState>();
                case "cancelled":
                    return _serviceProvider.GetService<CancelledEventState>();
                case "completed":
                    return _serviceProvider.GetService<CompletedEventState>();

                default:
                    throw new UserException("Action not allowed.");
            }
        }
    }
}
