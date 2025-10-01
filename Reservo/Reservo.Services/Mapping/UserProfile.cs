using AutoMapper;
using Reservo.Model.DTOs.User;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class UserProfile : Profile
    {
        public UserProfile()
        {

            CreateMap<UserInsertDTO, User>()
                .ForMember(dest => dest.CityId, opt => opt.Ignore())
                .ForMember(dest => dest.City, opt => opt.Ignore())
                .ConstructUsing(src =>
                    src.RoleId == 1 ? new Admin() :
                    src.RoleId == 2 ? new Client() :
                    src.RoleId == 3 ? new Organizer() :
                    new User());

            CreateMap<UserInsertDTO, Client>()
                .IncludeBase<UserInsertDTO, User>();

            CreateMap<UserInsertDTO, Organizer>()
                .IncludeBase<UserInsertDTO, User>();

            CreateMap<UserUpdateDTO, User>()
                .ForMember(dest => dest.Username, opt => opt.Ignore())
                .ForMember(dest => dest.City, opt => opt.Ignore())
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image != null ? Convert.FromBase64String(src.Image) : null))
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
            CreateMap<UserGetDTO, User>();
            CreateMap<User, UserInsertDTO>();
            CreateMap<User, UserUpdateDTO>()
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image != null ? Convert.ToBase64String(src.Image) : string.Empty));

            CreateMap<User, UserGetDTO>()
                .ForMember(dest => dest.Role, opt => opt.MapFrom(src => src.Role.Name))
                .ForMember(dest => dest.City, opt => opt.MapFrom(src => src.City.Name))
                .ForMember(dest => dest.CityId, opt => opt.MapFrom(src => src.City.Id))
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image != null ? Convert.ToBase64String(src.Image) : string.Empty));
        }
    }
}
