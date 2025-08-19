using Reservo.Model.DTOs.Ticket;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Order
{
    public class OrderInsertDTO
    {
        public int UserId { get; set; }
        public List<TicketOrderDTO> Tickets { get; set; }
    }
}
