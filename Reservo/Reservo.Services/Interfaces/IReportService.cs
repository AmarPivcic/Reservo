using Reservo.Model.DTOs.Report;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IReportService
    {
        Task<List<ProfitByCategoryDTO>> GetProfitByCategoryAsync(int organizerId, int year, int? month);
        Task<List<ProfitByMonthDTO>> GetProfitByMonthAsync(int organizerId, int year);
        Task<List<ProfitByDayDTO>> GetProfitByDayAsync(int organizerId, int year, int month);
    }
}
