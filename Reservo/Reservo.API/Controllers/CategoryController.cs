using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Category;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Services.Interfaces;
using Reservo.Services.Services;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class CategoryController : BaseController<Category, CategoryGetDTO, CategoryInsertDTO, CategoryUpdateDTO, CategorySearchObject>
    {
        public CategoryController(ICategoryService service, ILogger<BaseController<Category, CategoryGetDTO, CategoryInsertDTO, CategoryUpdateDTO, CategorySearchObject>> logger) : base(service, logger)
        {
        }

        [HttpDelete("DeleteCategory/{id}")]
        public async Task<IActionResult> DeleteCategory(int id)
        {
            var result = await (_service as ICategoryService).Delete(id);

            if (result != "OK")
                return BadRequest(result);

            return Ok();
        }
    }
}
