using Reservo.Model.DTOs.Order;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.OrderDetail
{
    public class OrderDetailsDTO
    {
        public int OrderId { get; set; }
        public double TotalAmount { get; set; }
        public string State { get; set; }
        public int EventId { get; set; }
        public string EventName { get; set; }
        public string Venue { get; set; }
        public DateTime EventDate { get; set; }
        public string City { get; set; }
        public string OrderedBy { get; set; }
        public List<OrderTicketDTO> Tickets { get; set; }
    }
}
