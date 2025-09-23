using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.OrderDetail
{
    public class OrderDetailInsertDTO
    {
        public int TicketTypeId { get; set; }
        public int Quantity { get; set; }
    }
}
