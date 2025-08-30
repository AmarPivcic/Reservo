using AutoMapper;
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

        public async override Task<EventGetDTO> Activate(Event entity)
        {
            bool validate = !string.IsNullOrWhiteSpace(entity.Name) && !string.IsNullOrWhiteSpace(entity.Description)
                            && entity.TicketTypes.Count > 0;
            if (validate)
            {
                entity.State = "active";

                await _context.SaveChangesAsync();

                return _mapper.Map<EventGetDTO>(entity);
            }
            else
            {
                throw new UserException("Please insert all event details before activating the event!");
            }
        }
    }
}
