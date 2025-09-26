using Reservo.Model.DTOs.Payment;
using Reservo.Model.Entities;
using Reservo.Services.Interfaces;
using Stripe;
using Stripe.Climate;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class StripeService : IStripeService
    {
        public async Task<IntentResponseDTO> CreatePaymentIntent(double amount)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)(amount * 100),
                Currency = "eur",
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true
                }
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options);

            var response = new IntentResponseDTO
            {
                clientSecret = paymentIntent.ClientSecret,
                paymentIntentId = paymentIntent.Id
            };

            return response;
        }

        public async Task CreateRefundAsync(string paymentIntentId)
        {
            var refundService = new RefundService();
            var refundOptions = new RefundCreateOptions
            {
                PaymentIntent = paymentIntentId,
            };
            await refundService.CreateAsync(refundOptions);
        }

        public async Task RefundTicketAsync(Ticket ticket, int quantity)
        {
            if (ticket.OrderDetail?.Order?.IsPaid == true && !string.IsNullOrEmpty(ticket.OrderDetail.Order.StripePaymentIntentId))
            {
                var options = new RefundCreateOptions
                {
                    PaymentIntent = ticket.OrderDetail.Order.StripePaymentIntentId,
                    Amount = (long)(ticket.OrderDetail.UnitPrice * quantity * 100),
                };

                var service = new RefundService();
                await service.CreateAsync(options);

            }
        }


    }
}
