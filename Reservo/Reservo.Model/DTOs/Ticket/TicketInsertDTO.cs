using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Ticket
{
    public class TicketInsertDTO
    {
        public string QRCode { get; set; }
        public int OrderDetailId { get; set; }
    }
}
