using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class Ticket
    {
        public int Id { get; set; }
        public string QRCode { get; set; }
        public bool IsUsed { get; set; }
        [ForeignKey(nameof(Order))]
        public int OrderId { get; set; }
        public Order Order { get; set; }
        [ForeignKey(nameof(TicketType))]
        public int TicketTypeId { get; set; }
        public TicketType TicketType { get; set; }
    }
}
