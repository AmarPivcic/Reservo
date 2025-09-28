using Reservo.Model.DTOs.Review;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IReviewService : IBaseService<Review, ReviewGetDTO, ReviewInsertDTO, ReviewUpdateDTO, ReviewSearchObject>
    {
        public Task<ReviewGetDTO> GetByOrderId(int orderId, int userId);
        public Task<IEnumerable<ReviewGetDTO>> GetByEventId(int eventId);
    }
}
