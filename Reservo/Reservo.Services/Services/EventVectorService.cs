using Microsoft.EntityFrameworkCore;
using Reservo.Model.Entities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class EventVectorService : IEventVectorService
    {
        private readonly ReservoContext _context;

        public EventVectorService(ReservoContext context)
        {
            _context = context;
        }

        public async Task<EventVector?> GetByEventIdAsync(int eventId)
        {
            return await _context.EventVectors.FindAsync(eventId);
        }

        public async Task UpsertAsync(EventVector vector)
        {
            var existing = await _context.EventVectors.FindAsync(vector.EventId);

            if (existing == null)
                await _context.EventVectors.AddAsync(vector);
            else
                existing.Vector = vector.Vector;

            await _context.SaveChangesAsync();
        }

        public async Task<List<EventVector>> GetAllWithEventAsync()
        {
            return await _context.EventVectors
                .Include(ev => ev.Event)
                .ToListAsync();
        }
    }

}
