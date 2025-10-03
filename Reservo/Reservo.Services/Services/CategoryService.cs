using AutoMapper;
using Microsoft.EntityFrameworkCore;
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

        public override async Task<string> Delete(int id)
        {
            var category = await _context.Categories
            .Include(c => c.Events)
            .FirstOrDefaultAsync(c => c.Id == id);

            if (category == null)
                return "Category not found.";

            if (category.Events.Any())
                return "Cannot delete category: it has related events.";

            _context.Categories.Remove(category);
            await _context.SaveChangesAsync();

            return "OK";
        }
    }
}
