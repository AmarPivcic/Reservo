using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.OrderDetail
{
    public class OrderDetailGetDTO
    {
        public int Id { get; set; }
        public int OrderId { get; set; }
        public int TicketTypeId { get; set; }
        public string TicketTypeName { get; set; }
        public int Quantity { get; set; }
        public double UnitPrice { get; set; }
        public double TotalPrice { get; set; }
        public int EventId { get; set; }
        public string EventName { get; set; }
    }
}
