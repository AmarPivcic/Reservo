using AutoMapper;
using Reservo.Model.DTOs.VenueRequest;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class VenueRequestService : BaseService<VenueRequest, VenueRequestGetDTO, VenueRequestInsertDTO, VenueRequestUpdateDTO, VenueRequestSearchObject>, IVenueRequestService
    {
        public VenueRequestService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {
        }

    }
}
