using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Review
{
    public class ReviewInsertDTO
    {
        public string? Comment { get; set; }
        public int Rating { get; set; }
        public int UserId { get; set; }
        public int EventId { get; set; }
    }
}
