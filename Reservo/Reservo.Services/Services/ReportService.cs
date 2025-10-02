using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Report;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class ReportService : IReportService
    {
        private readonly ReservoContext _context;
        public ReportService(ReservoContext context)
        {
            _context = context;
        }

        public async Task<List<ProfitByCategoryDTO>> GetProfitByCategoryAsync(int organizerId, int year, int? month = null)
        {
            var query = _context.OrderDetails
                .Include(od => od.TicketType)
                    .ThenInclude(tt => tt.Event)
                        .ThenInclude(e => e.Category)
                .Include(od => od.Order)
                .Where(od => od.TicketType.Event.OrganizerId == organizerId &&
                             od.Order.IsPaid &&
                             od.Order.OrderDate.Year == year);

            if (month.HasValue)
                query = query.Where(od => od.Order.OrderDate.Month == month.Value);

            return await query
                .GroupBy(od => od.TicketType.Event.Category.Name)
                .Select(g => new ProfitByCategoryDTO
                {
                    Category = g.Key,
                    Profit = g.Sum(od => od.TotalPrice) 
                })
                .ToListAsync();
        }

        public async Task<List<ProfitByMonthDTO>> GetProfitByMonthAsync(int organizerId, int year)
        {
            return await _context.OrderDetails
                .Include(od => od.TicketType)
                    .ThenInclude(tt => tt.Event)
                .Include(od => od.Order)
                .Where(od => od.TicketType.Event.OrganizerId == organizerId &&
                             od.Order.IsPaid &&
                             od.Order.OrderDate.Year == year)
                .GroupBy(od => od.Order.OrderDate.Month)
                .Select(g => new ProfitByMonthDTO
                {
                    Month = g.Key,
                    Profit = g.Sum(od => od.TotalPrice)
                })
                .OrderBy(x => x.Month)
                .ToListAsync();
        }

        public async Task<List<ProfitByDayDTO>> GetProfitByDayAsync(int organizerId, int year, int month)
        {
            return await _context.OrderDetails
                .Include(od => od.TicketType)
                    .ThenInclude(tt => tt.Event)
                .Include(od => od.Order)
                .Where(od => od.TicketType.Event.OrganizerId == organizerId &&
                             od.Order.IsPaid &&
                             od.Order.OrderDate.Year == year &&
                             od.Order.OrderDate.Month == month)
                .GroupBy(od => od.Order.OrderDate.Day)
                .Select(g => new ProfitByDayDTO
                {
                    Day = g.Key,
                    Profit = g.Sum(od => od.TotalPrice)
                })
                .OrderBy(x => x.Day)
                .ToListAsync();
        }
    }
}
