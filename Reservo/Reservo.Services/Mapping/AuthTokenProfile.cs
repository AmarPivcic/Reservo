using AutoMapper;
using Reservo.Model.DTOs.AuthToken;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class AuthTokenProfile : Profile
    {
        public AuthTokenProfile() 
        {
            CreateMap<AuthTokenInsertDTO, AuthToken>();
            CreateMap<AuthTokenUpdateDTO, AuthToken>();
            CreateMap<AuthTokenGetDTO, AuthToken>();
            CreateMap<AuthToken, AuthTokenInsertDTO>();
            CreateMap<AuthToken, AuthTokenUpdateDTO>();
            CreateMap<AuthToken, AuthTokenGetDTO>();
        }
    }
}
