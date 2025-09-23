using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Order
{
    public class UserOrderGetDTO
    {
        public int OrderId { get; set; }
        public string State { get; set; }
        public string EventName { get; set; }
        public string EventImage { get; set; }
        public DateTime OrderDate { get; set; }
    }
}
