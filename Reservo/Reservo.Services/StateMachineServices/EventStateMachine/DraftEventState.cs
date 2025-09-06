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
    }
}
