using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.DTOs.AuthToken
{
    public class AuthTokenGetDTO
    {
        public string Value { get; set; }
        public Entities.User User { get; set; }
        public DateTime Created {  get; set; }
        public DateTime? Revoked { get; set; }
    }
}
