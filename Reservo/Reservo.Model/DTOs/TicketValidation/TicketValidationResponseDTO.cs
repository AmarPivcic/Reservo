using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.TicketValidation
{
    public class TicketValidationResponseDTO
    {
        public bool IsValid { get; set; }
        public int? TicketId { get; set; }
        public string Message { get; set; }
    }
}
