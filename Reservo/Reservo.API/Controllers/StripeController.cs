using Microsoft.AspNetCore.Mvc;
using Reservo.Model.Entities;
using Reservo.Services.Database;
using Stripe;

namespace Reservo.API.Controllers
{
    [ApiController]
    [Route("api/stripe/webhook")]
    public class StripeController : ControllerBase
    {
        private readonly ReservoContext _context;
        private readonly IConfiguration _config;

        public StripeController(ReservoContext context, IConfiguration config)
        {
            _config = config;
            _context = context;
        }

        [HttpPost]
        public async Task<IActionResult> Index()
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
            try
            {
                var stripeEvent = EventUtility.ConstructEvent(
                    json,
                    Request.Headers["Stripe-Signature"],
                    _config["Stripe:WebhookSecret"]
                );

                if (stripeEvent.Type == "payment_intent.suceeded")
                {
                    var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
                    var order = _context.Orders.FirstOrDefault(o => o.StripePaymentIntentId == paymentIntent.Id);
                    if (order != null)
                    {
                        order.IsPaid = true;

                        foreach (var detail in order.OrderDetails)
                        {
                            var ticketType = await _context.TicketTypes.FindAsync(detail.TicketTypeId);
                            ticketType.Quantity -= detail.Quantity;

                            for (int i = 0; i < detail.Quantity; i++)
                            {
                                var ticket = new Ticket
                                {
                                    QRCode = Guid.NewGuid().ToString(),
                                    State = "Active",
                                    OrderDetailId = detail.Id
                                };
                                _context.Tickets.Add(ticket);
                            }
                        }

                        await _context.SaveChangesAsync();
                    }
                }

                return Ok();
            }
            catch (StripeException e)
            {
                return BadRequest(e.Message);
            }
        }
    }
}
