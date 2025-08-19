using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.Review
{
    public class ReviewGetDTO
    {
            public int Id { get; set; }
            public string Comment { get; set; }
            public int Rating { get; set; }
            public DateTime CreatedAt { get; set; }
            public string Username { get; set; }
            public string Event { get; set; }
    }
}
