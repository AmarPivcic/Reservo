using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Reservo.Model.DTOs.User;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.Utilities;
using System.Security.Claims;


namespace Reservo.Services.Services
{
    public class UserService : BaseService<User, UserGetDTO, UserInsertDTO, UserUpdateDTO, UserSearchObject>, IUserService
    {
        ILogger<UserService> _logger;
        public UserService(ReservoContext context, IMapper mapper, ILogger<UserService> logger) : base(context, mapper)
        {
            _logger = logger;
        }

        public override IQueryable<User> AddInclude(IQueryable<User> query, UserSearchObject? search = null)
        {
            query = query.Include("Role");
            query = query.Include("City");
            return base.AddInclude(query, search);
        }

        public override IQueryable<User> AddFilter(IQueryable<User> query, UserSearchObject? search = null)
        {
            if (search != null)
            {
                if (search!.Role != null)
                {
                    if (search!.Role != "allexceptadmin")
                    {
                        query = query.Where(u => u.Role.Name == search.Role);
                    }
                    else
                    {
                        query = query.Where(u => u.Role.Name != "admin");
                    }
                }

                if(search!.UserName != null)
                {
                    query = query.Where (u => u.Username == search.UserName);
                }

                if (search!.ContainsUsername != null)
                {
                    query = query.Where(u => u.Username.Contains(search.ContainsUsername));
                }

                if (search!.Active != null)
                {
                    query = query.Where(u => u.Active == search.Active);
                }
            }
            return base.AddFilter(query, search);
        }

        public async Task ChangeActiveStatus(int id)
        {
            var set = _context.Set<User>();
            var entity = await set.FirstOrDefaultAsync(u => u.Id == id);

            if(entity != null)
            {
                entity.Active = !entity.Active;
                await _context.SaveChangesAsync();

                var tokens = await _context.AuthTokens.Where(t => t.UserId == entity.Id).ToListAsync();

                foreach (var token in tokens)
                {
                    if(token.Revoked==null)
                    {
                        token.Revoked = DateTime.Now;
                        await _context.SaveChangesAsync();
                    }
                }
            }

            else
            {
                throw new UserException("Wrong user id!");
            }
        }

        public async Task UpdateImageByToken(UserUpdateImageDTO request)
        {
            var set = _context.Set<User>();
            var entity = await set.FirstOrDefaultAsync(u => u.Username == request.Username);

            if (entity != null)
            {
                if (request.Image != "")
                {
                    byte[] newImage = Convert.FromBase64String(request.Image);
                    entity.Image = newImage;
                }
                else
                {
                    entity.Image = null;
                }
                await _context.SaveChangesAsync();
            }

            else
            {
                throw new UserException($"User {request.Username} doesn't exist.");
            }
        }

        public async Task UpdateUsernameByToken(UserUpdateUsernameDTO request)
        {
            if (request.Username == request.NewUsername)
            {
                throw new UserException("New username can't be the same as the old one.");
            }

            var set = _context.Set<User>();
            var user = await set.FirstOrDefaultAsync(u => u.Username == request.NewUsername);

            if (user != null)
            {
                throw new UserException("This username is already taken.");
            }

            else
            {
                var entity = await set.FirstOrDefaultAsync(u => u.Username == request.Username);

                if(entity != null) 
                {
                    string passwordHash = Hashing.GenerateHash(entity.PasswordSalt, request.Password);
                    if (passwordHash != entity.PasswordHash)
                    {
                        throw new UserException("Wrong password.");
                    }
                    else
                    {
                        entity.Username = request.NewUsername!;
                    }
                    await _context.SaveChangesAsync();
                }

                else
                {
                    throw new UserException("User doesn't exist");
                }
            }
        }

        public async Task UpdatePasswordByToken(UserUpdatePasswordDTO request)
        {
            var set = _context.Set<User>();

            var entity = await set.FirstOrDefaultAsync(u => u.Id == request.userId);

            if(entity != null )
            {
                if (request.NewPassword != request.ConfirmNewPassword)
                {
                    throw new UserException("New password values don't match.");
                }

                string newPasswordHashOldSalt = Hashing.GenerateHash(entity.PasswordSalt, request.NewPassword);
                if(newPasswordHashOldSalt == entity.PasswordHash)
                {
                    throw new UserException("New password can't be the same as the old one.");
                }

                string oldPasswordHash = Hashing.GenerateHash(entity.PasswordSalt, request.OldPassword);
                if(oldPasswordHash != entity.PasswordHash)
                {
                    throw new UserException("Wrong old password.");
                }
                else
                {
                    entity.PasswordSalt = Hashing.GenerateSalt();
                    entity.PasswordHash = Hashing.GenerateHash(entity.PasswordSalt, request.NewPassword);
                }

                await _context.SaveChangesAsync();
            }
            else
            {
                throw new UserException("User doesn't exist");
            }
        }

        public async Task<UserGetDTO> UpdateByToken(UserUpdateDTO request)
        {
            var set = _context.Set<User>();

            var entity = await set.FirstOrDefaultAsync(u => u.Username == request.Username);

            if(entity != null)
            {
                _mapper.Map(request, entity);

                if (request.CityId != null)
                {
                    City? city = await _context.Cities.FirstOrDefaultAsync(c => c.Id == request.CityId);

                    if (city != null)
                    {
                        entity.CityId = city.Id;
                    }
                }
                await _context.SaveChangesAsync();

                return _mapper.Map<UserGetDTO>(entity);
            }

            else
            {
                throw new UserException("User doesn't exist.");
            }
        }

        public override async Task BeforeInsert(User entity, UserInsertDTO request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == request.Username);

            if(user == null)
            {
                if(request.Password != request.PasswordConfirm)
                {
                    throw new UserException("Passwords must match.");
                }

                entity.PasswordSalt = Hashing.GenerateSalt();
                entity.PasswordHash = Hashing.GenerateHash(entity.PasswordSalt, request.Password);
                entity.DateCreated = DateTime.Now.Date;

                City? city = await _context.Cities.FirstOrDefaultAsync(c => c.Name.ToLower() == request.City.ToLower());

                if (city!=null)
                {
                    entity.CityId = city.Id;
                }
                else
                {
                    var citySet = _context.Set<City>();
                    City newCity = new City
                    {
                        Name = request.Name
                    };
                    await citySet.AddAsync(newCity);
                    await _context.SaveChangesAsync();

                    entity.CityId = newCity.Id;
                }
                
                

                await base.BeforeInsert(entity, request);
            }
            else
            {
                throw new UserException("This username is already in use.");
            }
        }

        public async Task<UserGetDTO> GetCurrentUser(int id)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .Include(u => u.City).FirstOrDefaultAsync(u => u.Id == id);
            return _mapper.Map<UserGetDTO>(user);  
        }
    }
}
