using AutoMapper;
using Reservo.Model.DTOs.Order;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Stripe;


namespace Reservo.Services.Services
{
    public class OrderService : BaseService<Order, OrderGetDTO, OrderInsertDTO, OrderUpdateDTO, OrderSearchObject>, IOrderService
    {
        public OrderService(ReservoContext context, IMapper mapper) : base(context, mapper)
        {
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

                var options = new PaymentIntentCreateOptions
                {
                    Amount = (long)(totalAmount * 100),
                    Currency = "eur",
                    AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                    {
                        Enabled = true
                    }
                };

                var service = new PaymentIntentService();
                var paymentIntent = await service.CreateAsync(options);

                order.StripePaymentIntentId = paymentIntent.Id;

                _context.Orders.Add(order);
                await _context.SaveChangesAsync();

                return new OrderGetDTO
                {
                    Id = order.Id,
                    TotalAmount = order.TotalAmount,
                    StripeClientSecret = paymentIntent.ClientSecret
                };
        }
    }
}
