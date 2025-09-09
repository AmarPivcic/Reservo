using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class Event
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string? Description { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public byte[]? Image { get; set; }
        public string State { get; set; }
        [ForeignKey(nameof(Category))]
        public int CategoryId { get; set; }
        public Category Category { get; set; }
        [ForeignKey(nameof(Venue))]
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
        [ForeignKey(nameof(User))]
        public int OrganizerId { get; set; }
        public User User { get; set; }

        public ICollection<TicketType> TicketTypes { get; set; } = new List<TicketType>();

    }
}
