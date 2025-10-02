using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Event
{
    public class EventDataDTO
    {
        public int EventId { get; set; }
        public string Features { get; set; } = string.Empty;
    }
}
