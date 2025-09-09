using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IEventService : IBaseService<Event, EventGetDTO, EventInsertDTO, EventUpdateDTO, EventSearchObject>
    {
        Task<EventGetDTO> Activate(int id);
        Task<EventGetDTO> Cancel(int id);
        Task<List<string>> AllowedActions(int id);
        Task<EventGetDTO> Draft(int id);
    }
}
