using Reservo.Model.DTOs.Venue;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IVenueService : IBaseService<Venue, VenueGetDTO, VenueInsertDTO, VenueUpdateDTO, VenueSearchObject>
    {
        
    }
}
