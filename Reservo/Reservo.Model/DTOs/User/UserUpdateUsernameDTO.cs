using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.User
{
    public class UserUpdateUsernameDTO
    {
        public string? Username { get; set; }
        public string NewUsername { get; set; }
        public string Password { get; set; }
    }
}
