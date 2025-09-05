using AutoMapper;
using Reservo.Model.DTOs.Category;
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
    public class CategoryService : BaseService<Category, CategoryGetDTO, CategoryInsertDTO, CategoryUpdateDTO, CategorySearchObject>, ICategoryService
    {
        public CategoryService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {

        }
    }
}
