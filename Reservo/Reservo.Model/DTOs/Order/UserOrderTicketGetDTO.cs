using Reservo.Model.DTOs.Ticket;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Order
{
    public class UserOrderTicketGetDTO
    {
        public string TicketTypeName { get; set; }
        public int Quantity { get; set; }
        public double UnitPrice { get; set; }
        public double TotalPrice { get; set; }
        public List<TicketGetDTO> Tickets { get; set; }
    }
}
