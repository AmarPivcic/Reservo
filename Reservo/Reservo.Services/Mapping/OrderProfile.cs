using AutoMapper;
using Reservo.Model.DTOs.Order;
using Reservo.Model.DTOs.OrderDetail;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class OrderProfile : Profile
    {
        public OrderProfile()
        {
            CreateMap<Order, UserOrderGetDTO>()
            .ForMember(dest => dest.EventName,
                       opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                           ? src.OrderDetails.First().TicketType.Event.Name
                           : ""))
            .ForMember(dest => dest.EventImage,
                       opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                           ? Convert.ToBase64String(src.OrderDetails.First().TicketType.Event.Image)
                           : ""))
            .ForMember(dest => dest.State,
                       opt => opt.MapFrom(src => src.State))
            .ForMember(dest => dest.OrderDate,
                       opt => opt.MapFrom(src => src.OrderDate))
            .ForMember(dest => dest.OrderId,
                       opt => opt.MapFrom(src => src.Id));


            CreateMap<OrderDetail, UserOrderTicketGetDTO>()
                .ForMember(dest => dest.TicketTypeName, opt => opt.MapFrom(src => src.TicketType.Name))
                .ForMember(dest => dest.Quantity, opt => opt.MapFrom(src => src.Quantity))
                .ForMember(dest => dest.UnitPrice, opt => opt.MapFrom(src => src.UnitPrice))
                .ForMember(dest => dest.TotalPrice, opt => opt.MapFrom(src => src.TotalPrice))
                .ForMember(dest => dest.Tickets, opt => opt.MapFrom(src => src.Tickets));

            CreateMap<Order, UserOrderDetailGetDTO>()
                .ForMember(dest => dest.OrderId, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.TotalAmount, opt => opt.MapFrom(src => src.TotalAmount))
                .ForMember(dest => dest.State, opt => opt.MapFrom(src => src.State))
                .ForMember(dest => dest.EventId,
                           opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                               ? src.OrderDetails.First().TicketType.Event.Id
                               : 0))
                .ForMember(dest => dest.EventName,
                           opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                               ? src.OrderDetails.First().TicketType.Event.Name
                               : ""))
                .ForMember(dest => dest.EventImage,
                           opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                               ? Convert.ToBase64String(src.OrderDetails.First().TicketType.Event.Image)
                               : ""))
                .ForMember(dest => dest.Venue,
                           opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                               ? src.OrderDetails.First().TicketType.Event.Venue.Name
                               : ""))
                .ForMember(dest => dest.EventDate,
                           opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                               ? src.OrderDetails.First().TicketType.Event.StartDate
                               : DateTime.MinValue))
                .ForMember(dest => dest.City,
                           opt => opt.MapFrom(src => src.OrderDetails.FirstOrDefault() != null
                               ? src.OrderDetails.First().TicketType.Event.Venue.City.Name
                               : ""))
                .ForMember(dest => dest.Tickets,
                           opt => opt.MapFrom(src => src.OrderDetails));
        }
    }
}
