using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.SearchObjects
{
    public class EventSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? ContainsName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
