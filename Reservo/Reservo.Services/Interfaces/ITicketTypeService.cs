using Reservo.Model.DTOs.TicketType;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface ITicketTypeService : IBaseService<TicketType, TicketTypeGetDTO, TicketTypeInsertDTO, TicketTypeUpdateDTO, TicketTypeSearchObject>
    {
        Task<List<TicketTypeGetDTO>> GetTicketTypesByEvent(int eventId);
    }
}
