using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Review;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Stripe.Climate;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class ReviewService : BaseService<Review, ReviewGetDTO, ReviewInsertDTO, ReviewUpdateDTO, ReviewSearchObject>, IReviewService
    {
        public ReviewService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<ReviewGetDTO> Insert(ReviewInsertDTO request)
        {
            var review = _mapper.Map<Review>(request);

            var eventEntity = await _context.Events.FindAsync(request.EventId);
            if (eventEntity == null)
            {
                throw new UserException("Event not found!");
            }

            review.OrganizerId = eventEntity.OrganizerId;

            var user = await _context.Users.FindAsync(request.UserId);
            review.User = user;

            await _context.Reviews.AddAsync(review);
            await _context.SaveChangesAsync();

            return _mapper.Map<ReviewGetDTO>(review);
        }
        public async Task<IEnumerable<ReviewGetDTO>> GetByEventId(int eventId)
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Where(r => r.EventId == eventId).ToListAsync();

            if(reviews == null)
            {
                throw new UserException("Reviews not found for this event!");
            }
            
            return _mapper.Map<List<ReviewGetDTO>>(reviews);
        }

        public async Task<ReviewGetDTO?> GetByOrderId(int orderId, int userId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.TicketType)
                .ThenInclude(tt => tt.Event)
                .FirstOrDefaultAsync(o => o.Id == orderId && o.UserId == userId);
            if (order == null)
                throw new UserException("Order not found!");

            var review = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Event)
                .FirstOrDefaultAsync(r => r.EventId == order.OrderDetails
                    .First().TicketType.EventId
                    && r.UserId == order.UserId);

            if (review == null)
                return null;

            return _mapper.Map<ReviewGetDTO>(review);
        }
    }
}
