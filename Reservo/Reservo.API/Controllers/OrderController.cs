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
        public async Task<IActionResult> ConfirmOrderPayment(int orderId)
        {

            try
            {
                var result = await (_service as IOrderService).ConfirmOrderPayment(orderId);
                return Ok(new { success = result });
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }

        }

        [HttpGet("UserOrders")]
        public async Task<IActionResult> GetUserOrders()
        {

            try
            {
                int UserId;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
                {
                    UserId = userId;
                    var orders = await (_service as IOrderService).GetUserOrders(UserId);
                    return Ok(orders);
                }
                return BadRequest(new { message = "User not found!" });
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("UserPreviousOrders")]
        public async Task<IActionResult> GetUserPreviousOrders()
        {
            try
            {
                int UserId;
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
                {
                    UserId = userId;
                    var orders = await (_service as IOrderService).GetUserPreviousOrders(UserId);
                    return Ok(orders);
                }
                return BadRequest(new { message = "User not found!" });
            }
            catch (UserException ex)
            {

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("UserOrders/{orderId}")]
        public async Task<IActionResult> GetOrderDetail(int orderId)
        { 
            try
            {
                var orderDetail = await (_service as IOrderService).GetOrderDetail(orderId);
                return Ok(orderDetail);
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{orderId}/Cancel")]
        public async Task<IActionResult> CancelOrder(int orderId)
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

        [HttpDelete("DeleteOrder/{id}")]
        public async Task<IActionResult> DeleteCity(int id)
        {
            var result = await (_service as IOrderService).Delete(id);

            if (result != "OK")
                return BadRequest(result);

            return Ok();
        }
    }
}
