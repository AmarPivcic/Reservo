using AutoMapper;
using Reservo.Model.DTOs.Venue;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class VenueProfile : Profile
    {
        public VenueProfile()
        {
            CreateMap<VenueInsertDTO, Venue>();
            CreateMap<VenueUpdateDTO, Venue>();
            CreateMap<VenueGetDTO, Venue>();

            CreateMap<Venue, VenueGetDTO>()
                .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.City.Name));
            CreateMap<Venue, VenueUpdateDTO>();
            CreateMap<Venue, VenueInsertDTO>();
        }
    }
}
