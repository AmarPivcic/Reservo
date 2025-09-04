using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Model.Entities
{
    public class Category
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public byte[]? Image { get; set; }
    }
}
