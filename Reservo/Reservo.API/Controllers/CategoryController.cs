using Reservo.Model.DTOs.Category;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    public class CategoryController : BaseController<Category, CategoryGetDTO, CategoryInsertDTO, CategoryUpdateDTO, CategorySearchObject>
    {
        public CategoryController(ICategoryService service, ILogger<BaseController<Category, CategoryGetDTO, CategoryInsertDTO, CategoryUpdateDTO, CategorySearchObject>> logger) : base(service, logger)
        {
        }
    }
}
