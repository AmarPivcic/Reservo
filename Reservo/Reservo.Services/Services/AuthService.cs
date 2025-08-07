using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.DTOs.AuthToken;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Services
{
    public class AuthService : BaseService<AuthToken, AuthTokenGetDTO, AuthTokenInsertDTO, AuthTokenUpdateDTO, AuthTokenSearchObject>, IAuthService
    {
        private readonly string _secret;
        public AuthService(string secret, ReservoContext context, IMapper mapper) : base(context, mapper)
        {
            _secret = secret;
        }

        public async Task<string> Login(string username, string password, string role)
        {
            var user = await _context.Users.Include(x => x.Role).FirstOrDefaultAsync(x => x.Username == username);
            if (user == null)
            {
                throw new UserException("Incorrect login!");
            }

            var hash = Hashing.GenerateHash(user.PasswordSalt, password);
            if (hash != user.PasswordHash || user.Role.Name != role)
            {
                throw new UserException("Incorrect login!");
            }

            if (user.Active == false)
            {
                var admin = await _context.Users.Take(1).FirstOrDefaultAsync();
                throw new UserException($"Your account is inactive! Please contact the administrator! Phone: {admin!.Phone} Email: {admin.Email}");
            }

            var authToken = new AuthToken();
            authToken = JwtToken.GenerateToken(user, _secret);

            await _context.AuthTokens.AddAsync(authToken);
            await _context.SaveChangesAsync();

            return authToken.Value;
        }

        public async Task RevokeToken(string token)
        {
            AuthToken authToken = await _context.AuthTokens.SingleOrDefaultAsync(t => t.Value == token);
            if (authToken != null)
            {
                authToken.Revoked = DateTime.Now;
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> IsTokenRevoked(string token)
        {
            var authToken = await _context.AuthTokens.SingleOrDefaultAsync(t => t.Value == token);
            return authToken?.Revoked != null;
        }
    }
}
