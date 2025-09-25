using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Order;
using Reservo.Model.DTOs.OrderDetail;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;
using System.Security.Claims;
namespace Reservo.API.Controllers
{
    [ApiController]
    public class OrderController : BaseController<Order, OrderGetDTO, OrderInsertDTO, OrderUpdateDTO, OrderSearchObject>
    {
        public OrderController(IOrderService service, ILogger<BaseController<Order, OrderGetDTO, OrderInsertDTO, OrderUpdateDTO, OrderSearchObject>> logger) : base(service, logger)
        {
        }

        [HttpPost]
        public override async Task<OrderGetDTO> Insert([FromBody] OrderInsertDTO request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                request.UserId = userId;
            }

            return await (_service as IOrderService).CreateOrder(request);
        }

        [HttpPost("{orderId}/Confirm")]
        public async Task<IActionResult> ConfirmOrder(int orderId)
        {
            var result = await (_service as IOrderService).ConfirmOrderPayment(orderId);
            return Ok(new { success = result });
        }

        [HttpGet("UserOrders")]
        public async Task<IEnumerable<UserOrderGetDTO>> GetUserOrders()
        {
            int UserId;
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                UserId = userId;
                return await (_service as IOrderService).GetUserOrders(UserId);
            }

            throw new UserException("User not found!");
        }

        [HttpGet("UserPreviousOrders")]
        public async Task<IEnumerable<UserOrderGetDTO>> GetUserPreviousOrders()
        {
            int UserId;
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                UserId = userId;
                return await (_service as IOrderService).GetUserPreviousOrders(UserId);
            }

            throw new UserException("User not found!");
        }

        [HttpGet("UserOrders/{orderId}")]
        public async Task<UserOrderDetailGetDTO> GetOrderDetail(int orderId)
        {
            return await (_service as IOrderService).GetOrderDetail(orderId);
        }

        [HttpPut("{orderId}/Cancel")]
        public async Task<ActionResult> CancelOrder(int orderId)
        {
            try
            {
                await (_service as IOrderService).CancelOrder(orderId);
                return Ok(new { message = "Event cancelled successfully." });
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
