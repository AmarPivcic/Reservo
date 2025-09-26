using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Payment
{
    public class IntentResponseDTO
    {
        public string paymentIntentId { get; set; }
        public string clientSecret { get; set; }
    }
}
