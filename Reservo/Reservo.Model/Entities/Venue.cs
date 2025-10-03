using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class Venue
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public int Capacity { get; set; }
        public string? Description { get; set; }
        [ForeignKey(nameof(City))]
        public int CityId { get; set; }
        public City City { get; set; }

        public ICollection<VenueCategory> AllowedCategories { get; set; } = new List<VenueCategory>();
        public ICollection<Event> Events { get; set; }


    }
}
