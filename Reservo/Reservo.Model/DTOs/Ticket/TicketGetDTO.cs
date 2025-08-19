using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Ticket
{
    public class TicketGetDTO
    {
        public int Id { get; set; }
        public string QRCode { get; set; }
        public bool IsUsed { get; set; }
        public int OrderDetailId { get; set; }
    }
}
