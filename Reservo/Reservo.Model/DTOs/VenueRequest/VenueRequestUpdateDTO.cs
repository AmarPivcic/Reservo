using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.VenueRequest
{
    public class VenueRequestUpdateDTO
    {
        public string VenueName { get; set; }
        public string CityName { get; set; }
        public string Address { get; set; }
        public int Capacity { get; set; }
        public string State { get; set; }
        public List<int> AllowedCategoryIds { get; set; } = new();
        public string? SuggestedCategories { get; set; }
    }
}
