using AutoMapper;
using MassTransit;
using MassTransit.Transports;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ReservationEmailConsumer.Contracts;
using Reservo.Model.DTOs.User;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Database;
using Reservo.Services.Interfaces;
using Reservo.Services.Utilities;
using Stripe.Climate;
using System.Security.Claims;


namespace Reservo.Services.Services
{
    public class UserService : BaseService<User, UserGetDTO, UserInsertDTO, UserUpdateDTO, UserSearchObject>, IUserService
    {
        ILogger<UserService> _logger;
        private readonly IPublishEndpoint _publishEndpoint;
        public UserService(IPublishEndpoint publishEndpoint,ReservoContext context, IMapper mapper, ILogger<UserService> logger) : base(context, mapper)
        {
            _logger = logger;
            _publishEndpoint = publishEndpoint;
        }

        public async Task<float[]?> GetUserProfileVector(int userId)
        {
            var profile = await _context.UserProfiles
                .AsNoTracking()
                .FirstOrDefaultAsync(up => up.UserId == userId);

            return profile?.Vector;
        }

        public async Task UpdateUserProfileVector(int userId, float[] vector)
        {
            var profile = await _context.UserProfiles
                .FirstOrDefaultAsync(up => up.UserId == userId);

            if (profile == null)
            {
                profile = new UserProfile
                {
                    UserId = userId,
                    Vector = vector
                };
                await _context.UserProfiles.AddAsync(profile);
            }
            else
            {
                profile.Vector = vector;
            }

            await _context.SaveChangesAsync();
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
                    switch (search.Role)
                    {
                        case "allexceptadmin":
                            if (search.Active == true)
                            {
                                query = query.Where(u =>
                                    u.Role.Name != "admin" &&
                                    ((u is Client) || (u is Organizer ))
                                );
                            }
                            else
                            {
                                query = query.Where(u =>
                                    u.Role.Name != "admin" &&
                                    ((u is Client) || (u is Organizer && !(u as Organizer).IsPending))
                                );
                            }
                            break;

                        case "Organizer":
                            query = query.OfType<Organizer>().Where(o => o.IsPending);
                            break;

                        default:
                            query = query.Where(u => u.Role.Name == search.Role);
                            break;
                    }
                }


                if (search.UserName != null)
                {
                    query = query.Where(u => u.Username == search.UserName);
                }

                if (search.ContainsUsername != null)
                {
                    query = query.Where(u => u.Username.Contains(search.ContainsUsername));
                }
                if (search.Active != null)
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


        public async Task ActivateOrganizer(int id)
        {
            var set = _context.Set<User>();
            var entity = await set.FirstOrDefaultAsync(u => u.Id == id);

            if (entity != null)
            {
                entity.Active = !entity.Active;
                (entity as Organizer).IsPending = false;
                await _context.SaveChangesAsync();

                var tokens = await _context.AuthTokens.Where(t => t.UserId == entity.Id).ToListAsync();

                foreach (var token in tokens)
                {
                    if (token.Revoked == null)
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

                await _publishEndpoint.Publish(new ReservationEmailMessage
                {
                    UserEmail = entity.Email,
                    Subject = "Password changed",
                    BodyHtml = $"{entity.Username}, your password has been changed! If this wasn't you, please contact our support as soon as possible!"
                });
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
                        Name = request.City
                    };
                    await citySet.AddAsync(newCity);
                    await _context.SaveChangesAsync();

                    entity.CityId = newCity.Id;
                }
                await _publishEndpoint.Publish(new ReservationEmailMessage
                {
                    UserEmail = entity.Email,
                    Subject = "Account created",
                    BodyHtml = $"{entity.Username}, your account has been created! We are happy that you became a part of our community!"
                });
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

        public override async Task<string> Delete(int id)
        {
            var user = await _context.Users
                .Include(u => (u as Client).Orders)
                .Include(u => (u as Organizer).OrganizedEvents)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
                return "User not found!";

            if (user is Client client)
            {
                var ordersToDelete = await _context.Orders
                    .Where(o => o.State != "active")
                    .Include(o => o.OrderDetails)
                    .ToListAsync();

                foreach (var order in ordersToDelete)
                {
                    _context.OrderDetails.RemoveRange(order.OrderDetails);
                }

                _context.Orders.RemoveRange(ordersToDelete);
            }

            if (user is Organizer organizer)
            {
                if (organizer.OrganizedEvents.Any(e => e.State == "active" || e.State == "draft"))
                    return "Cannot delete organizer with active events. Cancel or delete them first! (Including draft events!)";

                foreach (var ev in organizer.OrganizedEvents)
                {
                    var ticketTypes = _context.TicketTypes
                        .Include(tt => tt.OrderDetails)
                            .ThenInclude(od => od.Tickets)
                        .Where(tt => tt.EventId == ev.Id)
                        .ToList();

                    foreach (var tt in ticketTypes)
                    {
                        foreach (var od in tt.OrderDetails)
                        {
                            _context.Tickets.RemoveRange(od.Tickets);
                        }
                        _context.OrderDetails.RemoveRange(tt.OrderDetails);
                    }
                    _context.TicketTypes.RemoveRange(ticketTypes);
                }
                _context.Events.RemoveRange(organizer.OrganizedEvents);
            }
            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return "OK";
        }

    }
}
