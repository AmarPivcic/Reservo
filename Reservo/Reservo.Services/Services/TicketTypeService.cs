using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Reservo.Model.DTOs.TicketType;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class TicketTypeService : BaseService<TicketType, TicketTypeGetDTO, TicketTypeInsertDTO, TicketTypeUpdateDTO, TicketTypeSearchObject>, ITicketTypeService
    {
        public TicketTypeService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public async Task<List<TicketTypeGetDTO>> GetTicketTypesByEvent(int eventId)
        {
            return await _context.Set<TicketType>()
                .Where(t => t.EventId == eventId)
                .Select(t => _mapper.Map<TicketTypeGetDTO>(t))
                .ToListAsync();
        }

        public override IQueryable<TicketType> AddFilter(IQueryable<TicketType> query, TicketTypeSearchObject? search = null)
        {
            if (search == null)
                return query;

            if(search.id.HasValue)
                query = query.Where(t => t.Id == search.id);
            return base.AddFilter(query, search);
        }

        public async Task<TicketTypeGetDTO> GetTicketTypeById(int id)
        {
            var entity = _context.TicketTypes.Find(id);
            return _mapper.Map<TicketTypeGetDTO>(entity);
        }
    }
}
