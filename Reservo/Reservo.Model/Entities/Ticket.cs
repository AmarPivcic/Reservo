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
        public string State { get; set; }
        [ForeignKey(nameof(OrderDetail))]
        public int OrderDetailId { get; set; }
        public OrderDetail OrderDetail { get; set; }
    }
}
