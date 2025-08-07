using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.AuthToken
{
    public class AuthTokenInsertDTO
    {
        public int Id { get; set; }
        public string Value { get; set; }
        public int UserId { get; set; }
        public DateTime Created { get; set; }
    }
}
