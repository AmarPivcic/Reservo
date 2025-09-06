using AutoMapper;
using Reservo.Model.DTOs.City;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class CityProfile : Profile
    {
        public CityProfile()
        {
            CreateMap<CityInsertDTO, City>();
            CreateMap<CityUpdateDTO, City>();

            CreateMap<City, CityGetDTO>();
            CreateMap<City, CityUpdateDTO>();
            CreateMap<City, CityInsertDTO>();

        }
    }
}
