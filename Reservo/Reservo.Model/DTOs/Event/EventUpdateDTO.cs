using Reservo.Model.DTOs.TicketType;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Event
{
    public class EventUpdateDTO
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? Image { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? CategoryId { get; set; }
        public int? VenueId { get; set; }
        public List<TicketTypeInsertDTO>? TicketTypes { get; set; } = new();
    }
}
