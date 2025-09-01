using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.SearchObjects
{
    public class EventSearchObject : BaseSearchObject
    {
        public int? OrganizerId { get; set; }
        public string? State { get; set; }
        public string? City { get; set; }
        public string? Venue { get; set; }
        public string? Name { get; set; }
        public DateTime? Date { get; set; }

    }
}
