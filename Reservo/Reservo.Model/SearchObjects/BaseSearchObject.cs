using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.SearchObjects
{
    public class BaseSearchObject
    {
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
    }
}
