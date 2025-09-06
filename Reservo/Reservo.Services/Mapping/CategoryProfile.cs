using AutoMapper;
using Reservo.Model.DTOs.Category;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class CategoryProfile : Profile
    {
        public CategoryProfile()
        {
            CreateMap<CategoryInsertDTO, Category>()
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image != null ? Convert.FromBase64String(src.Image) : null));
            CreateMap<CategoryUpdateDTO, Category>()
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image != null ? Convert.FromBase64String(src.Image) : null));

            CreateMap<Category, CategoryGetDTO>()
                .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image == null ? string.Empty : Convert.ToBase64String(src.Image)));
            CreateMap<Category, CategoryUpdateDTO>()
               .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image == null ? string.Empty : Convert.ToBase64String(src.Image)));
            CreateMap<Category, CategoryInsertDTO>()
               .ForMember(dest => dest.Image, opt => opt.MapFrom(src => src.Image == null ? string.Empty : Convert.ToBase64String(src.Image)));
        }
    }
}
