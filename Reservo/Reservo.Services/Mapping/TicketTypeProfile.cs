using AutoMapper;
using Reservo.Model.DTOs.TicketType;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Mapping
{
    public class TicketTypeProfile : Profile
    {
        public TicketTypeProfile()
        {
            CreateMap<TicketType, TicketTypeInsertDTO>();
            CreateMap<TicketType, TicketTypeUpdateDTO>();
            CreateMap<TicketType, TicketTypeGetDTO>();

            CreateMap<TicketTypeInsertDTO, TicketType>();
            CreateMap<TicketTypeUpdateDTO, TicketType>();
            CreateMap<TicketTypeGetDTO, TicketType>();
        }
    }
}
