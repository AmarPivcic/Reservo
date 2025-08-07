using Reservo.Model.DTOs.AuthToken;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IAuthService : IBaseService<AuthToken, AuthTokenGetDTO, AuthTokenInsertDTO, AuthTokenUpdateDTO, AuthTokenSearchObject>
    {
        Task<string> Login(string username, string password, string role);
        Task RevokeToken (string token);
        Task<bool> IsTokenRevoked (string token);
    }
}
