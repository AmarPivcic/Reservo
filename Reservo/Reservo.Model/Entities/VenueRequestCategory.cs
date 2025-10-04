using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class VenueRequestCategory
    {
        public int VenueRequestId { get; set; }
        public VenueRequest VenueRequest { get; set; }
        public int CategoryId { get; set; }
        public Category Category { get; set; }
    }
}
