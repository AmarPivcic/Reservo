using Reservo.Model.DTOs.Order;
using Reservo.Model.DTOs.OrderDetail;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IOrderService : IBaseService<Order, OrderGetDTO, OrderInsertDTO, OrderUpdateDTO, OrderSearchObject>
    {
        public Task<OrderGetDTO> CreateOrder(OrderInsertDTO request);
        public Task<bool> ConfirmOrderPayment(int orderId);
        public Task<IEnumerable<UserOrderGetDTO>> GetUserOrders(int userId);
        public Task<IEnumerable<UserOrderGetDTO>> GetUserPreviousOrders(int userId);
        public Task<UserOrderDetailGetDTO> GetOrderDetail(int orderId);
        public Task CancelOrder(int orderId);
    }
}
