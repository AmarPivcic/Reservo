using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.Order;
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
    }
}
