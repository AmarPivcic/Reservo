using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class VenueCategory
    {
        public int VenueId { get; set; }
        public Venue Venue { get; set; }
        public int CategoryId { get; set; }
        public Category Category { get; set; }
    }
}
