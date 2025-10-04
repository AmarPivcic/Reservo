using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class Organizer : User
    {
        public bool IsPending { get; set; } = true;
        public ICollection<Event> OrganizedEvents { get; set; }
        public ICollection<Review> ReviewsReceived { get; set; }

    }
}
