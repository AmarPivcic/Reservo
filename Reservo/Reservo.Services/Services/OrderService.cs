using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.Order;
using Reservo.Model.DTOs.OrderDetail;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using MassTransit;
using Reservo.Contracts;



namespace Reservo.Services.Services
{
    public class OrderService : BaseService<Order, OrderGetDTO, OrderInsertDTO, OrderUpdateDTO, OrderSearchObject>, IOrderService
    {
        private readonly IStripeService _stripeService;
        private readonly IPublishEndpoint _publishEndpoint;
        public OrderService(ReservoContext context, IMapper mapper, IStripeService stripeService, IPublishEndpoint publishEndpoint) : base(context, mapper)
        {
            _stripeService = stripeService;
            _publishEndpoint = publishEndpoint;
        }

        public async Task<OrderGetDTO> CreateOrder(OrderInsertDTO request)
        {
            var order = new Order
            {
                UserId = request.UserId!.Value,
                OrderDate = DateTime.Now,
                OrderDetails = new List<OrderDetail>(),
                IsPaid = false
            };

            double totalAmount = 0;

            foreach (var detailReq in request.OrderDetails)
            {
                var ticketType = await _context.TicketTypes.FindAsync(detailReq.TicketTypeId);

                if (ticketType == null)
                    throw new UserException($"TicketType {detailReq.TicketTypeId} not found");

                if (ticketType.Quantity < detailReq.Quantity)
                    throw new UserException($"Not enough tickets available for {ticketType.Name}");

                var unitPrice = ticketType.Price;
                var totalPrice = unitPrice * detailReq.Quantity;

                var orderDetail = new OrderDetail
                {
                    TicketTypeId = ticketType.Id,
                    Quantity = detailReq.Quantity,
                    UnitPrice = unitPrice,
                    TotalPrice = totalPrice,
                };

                order.OrderDetails.Add(orderDetail);
                totalAmount += totalPrice;
            }

            order.TotalAmount = totalAmount;

            var paymentIntent = await _stripeService.CreatePaymentIntent(totalAmount);

            order.StripePaymentIntentId = paymentIntent.paymentIntentId;

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            return new OrderGetDTO
            {
                Id = order.Id,
                TotalAmount = order.TotalAmount,
                StripeClientSecret = paymentIntent.clientSecret
            };
        }

        public async Task<bool> ConfirmOrderPayment(int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                .Include(o => o.User)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null) throw new UserException("Order not found");
            if (order.IsPaid) return true;

            order.IsPaid = true;

            foreach (var detail in order.OrderDetails)
            {
                var ticketType = await _context.TicketTypes.FindAsync(detail.TicketTypeId);
                if (ticketType == null) continue;

                ticketType.Quantity -= detail.Quantity;

                for (int i = 0; i < detail.Quantity; i++)
                {
                    var ticket = new Ticket
                    {
                        QRCode = Guid.NewGuid().ToString(),
                        State = "active",
                        OrderDetailId = detail.Id
                    };
                    _context.Tickets.Add(ticket);
                }
            }

            await _context.SaveChangesAsync();


            await _publishEndpoint.Publish(new ReservationEmailMessage
            {
                UserEmail = order.User.Email,
                Subject = "Order Confirmation",
                BodyHtml = $"Thank you {order.User.Username}, your order #{order.Id} has been confirmed! You can check it out in 'Active Orders' section!"
            });

            return true;
        }


        public async Task<IEnumerable<UserOrderGetDTO>> GetUserOrders(int userId)
        {
            var orders = await _context.Orders
                .Where(o => o.UserId == userId && o.State == "active")
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.TicketType)
                .ThenInclude(tt => tt.Event)
                .ToListAsync();

            return _mapper.Map<IEnumerable<UserOrderGetDTO>>(orders);
        }

        public async Task<IEnumerable<UserOrderGetDTO>> GetUserPreviousOrders(int userId)
        {
            var orders = await _context.Orders
                .Where(o => o.UserId == userId && o.State != "active")
                .Include(o => o.OrderDetails)
                .ThenInclude(od => od.TicketType)
                .ThenInclude(tt => tt.Event)
                .ToListAsync();

            return _mapper.Map<IEnumerable<UserOrderGetDTO>>(orders);
        }

        public async Task<UserOrderDetailGetDTO> GetOrderDetail(int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Tickets)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.TicketType)
                    .ThenInclude(tt => tt.Event)
                    .ThenInclude(e => e.Venue)
                    .ThenInclude(v => v.City)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null)
                throw new UserException("Order not found!");

            return _mapper.Map<UserOrderDetailGetDTO>(order);
        }

        public async Task CancelOrder(int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Tickets)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.TicketType)
                    .ThenInclude(tt => tt.Event)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null) throw new UserException("Order not found");
            if (order.State == "cancelled") throw new UserException("Order already cancelled");

            var eventDate = order.OrderDetails.First().TicketType.Event.StartDate;
            if (eventDate <= DateTime.Now.AddDays(3))
                throw new UserException("Orders can only be cancelled at least 3 days before the event");

            await CancelOrderLogic(order);
        }

        public async Task CancelOrderLogic(Order order)
        {
            await _stripeService.CreateRefundAsync(order.StripePaymentIntentId);

            order.State = "cancelled";
            order.IsPaid = false;
            
            foreach (var detail in order.OrderDetails)
            {
                var ticketType = detail.TicketType;
                ticketType.Quantity += detail.Quantity;

                foreach (var ticket in detail.Tickets)
                    ticket.State = "cancelled";
            }

            await _context.SaveChangesAsync();
            var orderMail = await _context.Orders
                .Include(o => o.User)
                .FirstOrDefaultAsync(o => o.Id == order.Id);

            await _publishEndpoint.Publish(new ReservationEmailMessage
            {
                UserEmail = orderMail.User.Email,
                Subject = "Order cancelled",
                BodyHtml = $"{orderMail.User.Username}, your order #{orderMail.Id} has been cancelled! You can check it out in 'Previous Orders' section!"
            });
        }

        public override async Task<string> Delete(int id)
        {
            var order = await _context.Orders
                .FirstOrDefaultAsync(o => o.Id == id);
            if (order.State == "active")
            {
                return "Cannot delete active order, cancel it first!";
            }

            _context.Orders.Remove(order);
            await _context.SaveChangesAsync();

            return "OK";
        }

    }
}
