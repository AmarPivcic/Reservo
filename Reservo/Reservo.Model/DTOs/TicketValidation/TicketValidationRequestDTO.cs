using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.TicketValidation
{
    public class TicketValidationRequestDTO
    {
        public int EventId { get; set; }
        public string QrCode { get; set; }
    }
}
