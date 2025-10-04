using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public byte[]? Image { get; set; }
        public ICollection<VenueCategory> Venues { get; set; } = new List<VenueCategory>();
        public ICollection<Event> Events;
        public ICollection<VenueRequestCategory> VenueRequestCategories { get; set; } = new List<VenueRequestCategory>();
    }
}
