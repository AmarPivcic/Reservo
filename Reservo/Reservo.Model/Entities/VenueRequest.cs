using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class VenueRequest
    {
        public int Id { get; set; }
        [ForeignKey(nameof(User))]
        public int OrganizerId { get; set; }
        public User Organizer { get; set; }
        public string VenueName { get; set; }
        public string CityName { get; set; }
        public string Address { get; set; }
        public int Capacity { get; set; }
        public string? Description { get; set; }
        public ICollection<VenueRequestCategory> VenueRequestCategories { get; set; } = new List<VenueRequestCategory>();
        public string? SuggestedCategories { get; set; }
        public string State { get; set; } = "Pending";
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }

}
