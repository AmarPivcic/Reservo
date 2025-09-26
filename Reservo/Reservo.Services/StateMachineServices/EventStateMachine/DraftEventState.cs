using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Reservo.Model.DTOs.Event;
using Reservo.Model.Entities;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.StateMachineServices.EventStateMachine
{
    public class DraftEventState : BaseEventState
    {
        public DraftEventState(ReservoContext context, IMapper mapper, IServiceProvider serviceProvider) : base(context, mapper, serviceProvider)
        {
        }

        public async override Task<EventGetDTO> Activate(int id)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                entity.State = "active";

                await _context.SaveChangesAsync();

                return _mapper.Map<EventGetDTO>(entity);
            }
            else
            {
                throw new UserException("Event not found!");
            }
        }

        public override async Task<EventGetDTO> Update(int id, EventUpdateDTO request)
        {
            var entity = await _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .Include(e => e.User)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (entity == null)
                throw new UserException("Event not found!");

            _mapper.Map(request, entity);

            entity.TicketTypes.Clear();
            foreach (var ticketTypeDto in request.TicketTypes)
            {
                var ticketType = _mapper.Map<TicketType>(ticketTypeDto);
                ticketType.Event = entity;

                entity.TicketTypes.Add(ticketType);
            }


            await _context.SaveChangesAsync();

            var updatedEntity = await _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .FirstOrDefaultAsync(e => e.Id == id);

            return _mapper.Map<EventGetDTO>(entity);
        }

        public override async Task<EventGetDTO> Draft(int id)
        {
            var entity = await _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                entity.State = "draft";

                await _context.SaveChangesAsync();
            }
            else
            {
                throw new UserException("Event not found!");
            }

            return _mapper.Map<EventGetDTO>(entity);
        }

        public override async Task<EventGetDTO> Cancel(int id)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                entity.State = "cancelled";

                await _context.SaveChangesAsync();
            }
            else
            {
                throw new UserException("Event not found!");
            }

            var updatedEntity = _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .FirstOrDefault(e => e.Id == id);

            return _mapper.Map<EventGetDTO>(updatedEntity);
        }

        public override async Task<EventGetDTO> Complete(int id)
        {
            var entity = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);

            if (entity != null)
            {
                entity.State = "completed";

                await _context.SaveChangesAsync();
            }
            else
            {
                throw new UserException("Event not found!");
            }

            var updatedEntity = _context.Events
                .Include(e => e.TicketTypes)
                .Include(e => e.Category)
                .Include(e => e.Venue)
                .FirstOrDefault(e => e.Id == id);

            return _mapper.Map<EventGetDTO>(updatedEntity);
        }

        public override async Task<string> Delete(int id)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var ev = await _context.Events
                    .Include(e => e.TicketTypes)
                        .ThenInclude(tt => tt.OrderDetails)
                .ThenInclude(od => od.Tickets)
                    .FirstOrDefaultAsync(e => e.Id == id);

                if (ev == null)
                    throw new UserException("Event not found");

                foreach (var ticketType in ev.TicketTypes)
                {
                    foreach (var orderDetail in ticketType.OrderDetails)
                    {
                        foreach (var ticket in orderDetail.Tickets)
                        {
                            await (_serviceProvider as IStripeService).RefundTicketAsync(ticket, orderDetail.Quantity);
                        }
                    }
                }

                _context.Events.Remove(ev);

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return "Event deleted and refunds processed successfully.";
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                throw new UserException($"Event deletion failed: {ex.Message}");
            }
        }
    }
}
