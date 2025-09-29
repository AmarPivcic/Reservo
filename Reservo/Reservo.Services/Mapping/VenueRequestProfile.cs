using AutoMapper;
using Reservo.Model.DTOs.VenueRequest;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class VenueRequestProfile : Profile
    {
        public VenueRequestProfile()
        {
            CreateMap<VenueRequestInsertDTO, VenueRequest>()
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore())
                .ForMember(dest => dest.State, opt => opt.Ignore());

            CreateMap<VenueRequest, VenueRequestGetDTO>()
                .ForMember(dest => dest.OrganizerName, opt => opt.MapFrom(src => src.Organizer.Username));
        }
    }
}
