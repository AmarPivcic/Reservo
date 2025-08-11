using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? UserName { get; set; }
        public string? ContainsUsername { get; set; }
        public bool? Active { get; set; }
        public string? Role { get; set; }
    }
}
