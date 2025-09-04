using AutoMapper;
using Microsoft.IdentityModel.Tokens;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class EventProfile : Profile
    {
        public EventProfile()
        {
            CreateMap<Event, EventGetDTO>()
                .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category.Name))
                .ForMember(dest => dest.VenueName, opt => opt.MapFrom(src => src.Venue.Name))
                .ForMember(dest => dest.OrganizerName, opt => opt.MapFrom(src => src.User.Name))
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image ?? src.Category.Image))
                .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.Venue.City.Name));
            CreateMap<Event, EventUpdateDTO>();
            CreateMap<Event, EventInsertDTO>()
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image == null ? string.Empty : Convert.ToBase64String(src.Image)));


            CreateMap<EventInsertDTO, Event>()
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image != null ? Convert.FromBase64String(src.Image) : null));
            CreateMap<EventUpdateDTO, Event>()
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image != null ? Convert.FromBase64String(src.Image) : null));
        }
    }
}
