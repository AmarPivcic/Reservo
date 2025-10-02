using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IEventVectorService
    {
        Task<EventVector?> GetByEventIdAsync(int eventId);
        Task UpsertAsync(EventVector vector);
        Task<List<EventVector>> GetAllWithEventAsync();
    }
}
