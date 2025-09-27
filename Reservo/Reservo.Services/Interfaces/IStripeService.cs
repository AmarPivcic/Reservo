using Reservo.Model.DTOs.Payment;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IStripeService
    {
        Task RefundTicketAsync(OrderDetail orderDetail);
        Task CreateRefundAsync(string paymentIntentId);
        Task<IntentResponseDTO> CreatePaymentIntent(double amount);
    }
}
