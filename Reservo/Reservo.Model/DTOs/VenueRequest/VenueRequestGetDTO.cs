using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.VenueRequest
{
    public class VenueRequestGetDTO
    {
        public int Id { get; set; }
        public string OrganizerName { get; set; }
        public string VenueName { get; set; }
        public string CityName { get; set; }
        public string Address { get; set; }
        public int Capacity { get; set; }
        public string? Description { get; set; }
        public string AllowedCategories { get; set; }
        public string State { get; set; } = "Pending";
        public DateTime CreatedAt { get; set; }
    }
}
