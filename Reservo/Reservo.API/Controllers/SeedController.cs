using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Reservo.Model.Entities;
using Reservo.Services.Database;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace Reservo.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DataSeedController : ControllerBase
    {
        private readonly ReservoContext _context;

        public DataSeedController(ReservoContext context)
        {
            _context = context;
        }

        [HttpPost("Seed")]
        public async Task<IActionResult> Seed()
        {
            //---------------------------------------------------
            // 1. CITIES
            //---------------------------------------------------
            if (!await _context.Cities.AnyAsync())
            {
                await _context.Cities.AddRangeAsync(new[]
                {
                    new City { Name = "Sarajevo" },
                    new City { Name = "Mostar" },
                    new City { Name = "Tuzla" }
                });
                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 2. CATEGORIES
            //---------------------------------------------------
            if (!await _context.Categories.AnyAsync())
            {
                await _context.Categories.AddRangeAsync(new[]
                {
                    new Category { Name = "Concerts" },
                    new Category { Name = "Sports" },
                    new Category { Name = "Theater" },
                    new Category { Name = "Conferences" },
                    new Category { Name = "Exhibitions" },
                    new Category { Name = "Festivals" }
                });
                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 3. ROLES
            //---------------------------------------------------
            if (!await _context.Roles.AnyAsync())
            {
                await _context.Roles.AddRangeAsync(new[]
                {
                    new Role { Name = "Admin", Description = "Administrator role" },
                    new Role { Name = "Client", Description = "Regular user role" },
                    new Role { Name = "Organizer", Description = "Event organizer role" }
                });
                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 4. USERS
            //---------------------------------------------------
            if (!await _context.Users.AnyAsync())
            {
                var sarajevo = await _context.Cities.FirstAsync(c => c.Name == "Sarajevo");
                var mostar = await _context.Cities.FirstAsync(c => c.Name == "Mostar");

                var adminRole = await _context.Roles.FirstAsync(r => r.Name == "Admin");
                var organizerRole = await _context.Roles.FirstAsync(r => r.Name == "Organizer");
                var clientRole = await _context.Roles.FirstAsync(r => r.Name == "Client");

                var admin = new Admin
                {
                    Name = "Admin",
                    Surname = "One",
                    Email = "admin@example.com",
                    Phone = "063063063",
                    Username = "admin1",
                    DateCreated = DateTime.Now,
                    Gender = "Other",
                    PasswordHash = "kcitE9/MDhEcqZS2HWYN4rnhWMg=",
                    PasswordSalt = "tEXKPiAApCKh+jkWWlXkJA==",
                    Active = true,
                    CityId = sarajevo.Id,
                    RoleId = adminRole.Id
                };

                var org1 = new Organizer
                {
                    Name = "Org",
                    Surname = "One",
                    Email = "organizer1@example.com",
                    Phone = "000000001",
                    Username = "organizer1",
                    DateCreated = DateTime.Now,
                    Gender = "Other",
                    PasswordHash = "xoeJkUgPPT46NsaPDQUE9JfYTpY=",
                    PasswordSalt = "8XGfbo6VEJ5ySk0yfiSqQA==",
                    Active = true,
                    CityId = sarajevo.Id,
                    RoleId = organizerRole.Id
                };

                var org2 = new Organizer
                {
                    Name = "Org",
                    Surname = "Two",
                    Email = "organizer2@example.com",
                    Phone = "000000002",
                    Username = "organizer2",
                    DateCreated = DateTime.Now,
                    Gender = "Other",
                    PasswordHash = "NbGYbtmTj3NGX9jLVviz2IQAYio=",
                    PasswordSalt = "xP6sMgu4tyaEXRSZK9pCBw==",
                    Active = true,
                    CityId = sarajevo.Id,
                    RoleId = organizerRole.Id
                };

                var client = new Client
                {
                    Name = "Client",
                    Surname = "One",
                    Email = "client1@example.com",
                    Phone = "000000003",
                    Username = "client1",
                    DateCreated = DateTime.Now,
                    Gender = "Other",
                    PasswordHash = "ed8emqzi9e8B8JCIB7HwjmGQtMs=",
                    PasswordSalt = "FQ7/B+OPZZCwH8jKn5Zy6g==",
                    Active = true,
                    CityId = mostar.Id,
                    RoleId = clientRole.Id
                };

                await _context.Users.AddRangeAsync(admin, org1, org2, client);
                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 5. VENUES
            //---------------------------------------------------
            if (!await _context.Venues.AnyAsync())
            {
                var sarajevo = await _context.Cities.FirstAsync(c => c.Name == "Sarajevo");
                var mostar = await _context.Cities.FirstAsync(c => c.Name == "Mostar");
                var tuzla = await _context.Cities.FirstAsync(c => c.Name == "Tuzla");

                await _context.Venues.AddRangeAsync(new[]
                {
                    new Venue { Name = "Zetra Olympic Hall", Address = "Alipašina bb, Sarajevo", Capacity = 12000, Description = "Indoor sports, concerts, and exhibitions arena", CityId = sarajevo.Id },
                    new Venue { Name = "Koševo Stadium", Address = "Maršala Tita bb, Sarajevo", Capacity = 34000, Description = "National football stadium", CityId = sarajevo.Id },
                    new Venue { Name = "National Theater Sarajevo", Address = "Obala Kulina bana 9, Sarajevo", Capacity = 600, Description = "Historic theater venue", CityId = sarajevo.Id },
                    new Venue { Name = "Bijeli Brijeg Stadium", Address = "Stjepana Radića bb, Mostar", Capacity = 25000, Description = "Home stadium of HŠK Zrinjski Mostar", CityId = mostar.Id },
                    new Venue { Name = "Herceg Stjepan Kosača Hall", Address = "Trg hrvatskih velikana, Mostar", Capacity = 1000, Description = "Cultural and concert hall", CityId = mostar.Id },
                    new Venue { Name = "Mostar Youth Theater", Address = "Maršala Tita 15, Mostar", Capacity = 400, Description = "Local theater hall", CityId = mostar.Id },
                    new Venue { Name = "Mejdan Sports Center", Address = "Slatina bb, Tuzla", Capacity = 8000, Description = "Sports and concert arena in Tuzla", CityId = tuzla.Id },
                    new Venue { Name = "Tuzla Cultural Center", Address = "Aleja Alije Izetbegovića 10, Tuzla", Capacity = 1200, Description = "Modern cultural events venue", CityId = tuzla.Id }
                });
                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 6. VENUE CATEGORIES
            //---------------------------------------------------
            if (!await _context.VenueCategories.AnyAsync())
            {
                var venues = await _context.Venues.ToListAsync();
                var categories = await _context.Categories.ToListAsync();

                void Add(string venueName, string categoryName)
                {
                    var venue = venues.First(v => v.Name == venueName);
                    var category = categories.First(c => c.Name == categoryName);
                    _context.VenueCategories.Add(new VenueCategory { VenueId = venue.Id, CategoryId = category.Id });
                }

                Add("Zetra Olympic Hall", "Concerts");
                Add("Zetra Olympic Hall", "Sports");
                Add("Zetra Olympic Hall", "Exhibitions");
                Add("Zetra Olympic Hall", "Festivals");

                Add("Koševo Stadium", "Concerts");
                Add("Koševo Stadium", "Sports");
                Add("Koševo Stadium", "Festivals");

                Add("National Theater Sarajevo", "Concerts");
                Add("National Theater Sarajevo", "Theater");

                Add("Bijeli Brijeg Stadium", "Concerts");
                Add("Bijeli Brijeg Stadium", "Sports");
                Add("Bijeli Brijeg Stadium", "Festivals");

                Add("Herceg Stjepan Kosača Hall", "Concerts");
                Add("Herceg Stjepan Kosača Hall", "Conferences");

                Add("Mostar Youth Theater", "Concerts");
                Add("Mostar Youth Theater", "Theater");

                Add("Mejdan Sports Center", "Concerts");
                Add("Mejdan Sports Center", "Sports");

                Add("Tuzla Cultural Center", "Concerts");
                Add("Tuzla Cultural Center", "Theater");
                Add("Tuzla Cultural Center", "Conferences");

                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 7. EVENTS
            //---------------------------------------------------
            if (!await _context.Events.AnyAsync())
            {
                var venues = await _context.Venues.ToListAsync();
                var categories = await _context.Categories.ToListAsync();
                var org1 = await _context.Users.FirstAsync(u => u.Username == "organizer1");
                var org2 = await _context.Users.FirstAsync(u => u.Username == "organizer2");

                await _context.Events.AddRangeAsync(new[]
                {
                    new Event { Name = "Rock Concert - Bijelo Dugme Tribute", Description = "A tribute concert for the legendary band.", StartDate = new DateTime(2025,10,18,20,0,0), EndDate = new DateTime(2025,10,18,23,0,0), State = "active", CategoryId = categories.First(c => c.Name == "Concerts").Id, VenueId = venues.First(v => v.Name == "Zetra Olympic Hall").Id, OrganizerId = org1.Id },
                    new Event { Name = "FK Sarajevo vs Željezničar", Description = "The famous Sarajevo derby.", StartDate = new DateTime(2025,10,25,18,0,0), EndDate = new DateTime(2025,10,25,20,0,0), State = "active", CategoryId = categories.First(c => c.Name == "Sports").Id, VenueId = venues.First(v => v.Name == "Koševo Stadium").Id, OrganizerId = org1.Id },
                    new Event { Name = "Hamlet - National Theater Sarajevo", Description = "Shakespeare’s Hamlet performed by the National Ensemble.", StartDate = new DateTime(2025,10,30,19,30,0), EndDate = new DateTime(2025,10,30,22,0,0), State = "active", CategoryId = categories.First(c => c.Name == "Theater").Id, VenueId = venues.First(v => v.Name == "National Theater Sarajevo").Id, OrganizerId = org1.Id },
                    new Event { Name = "Zrinjski Mostar vs Velež Mostar", Description = "The Mostar derby at Bijeli Brijeg.", StartDate = new DateTime(2025,11,5,19,0,0), EndDate = new DateTime(2025,11,5,21,0,0), State = "active", CategoryId = categories.First(c => c.Name == "Sports").Id, VenueId = venues.First(v => v.Name == "Bijeli Brijeg Stadium").Id, OrganizerId = org1.Id },
                    new Event { Name = "Mostar Summer Jazz Festival", Description = "Annual jazz festival featuring international artists.", StartDate = new DateTime(2025,11,15,20,0,0), EndDate = new DateTime(2025,11,15,23,30,0), State = "active", CategoryId = categories.First(c => c.Name == "Concerts").Id, VenueId = venues.First(v => v.Name == "Herceg Stjepan Kosača Hall").Id, OrganizerId = org1.Id },
                    new Event { Name = "Theater Play - Hasanaginica", Description = "Classic Bosnian play at the Mostar Youth Theater.", StartDate = new DateTime(2025,11,20,19,0,0), EndDate = new DateTime(2025,11,20,21,0,0), State = "active", CategoryId = categories.First(c => c.Name == "Theater").Id, VenueId = venues.First(v => v.Name == "Mostar Youth Theater").Id, OrganizerId = org2.Id },
                    new Event { Name = "International Conference on AI", Description = "Academic conference on artificial intelligence.", StartDate = new DateTime(2025,11,25,9,0,0), EndDate = new DateTime(2025,11,27,17,0,0), State = "active", CategoryId = categories.First(c => c.Name == "Conferences").Id, VenueId = venues.First(v => v.Name == "Tuzla Cultural Center").Id, OrganizerId = org2.Id },
                    new Event { Name = "Auto Expo Tuzla", Description = "Exhibition of new car models and technologies.", StartDate = new DateTime(2025,11,30,10,0,0), EndDate = new DateTime(2025,11,30,18,0,0), State = "active", CategoryId = categories.First(c => c.Name == "Exhibitions").Id, VenueId = venues.First(v => v.Name == "Mejdan Sports Center").Id, OrganizerId = org2.Id },
                    new Event { Name = "Summer Rock Festival", Description = "Big outdoor rock festival in Sarajevo.", StartDate = new DateTime(2025,9,10,18,0,0), EndDate = new DateTime(2025,9,10,23,30,0), State = "completed", CategoryId = categories.First(c => c.Name == "Concerts").Id, VenueId = venues.First(v => v.Name == "Zetra Olympic Hall").Id, OrganizerId = org1.Id }
                });
                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 8. TICKET TYPES
            //---------------------------------------------------
            if (!await _context.TicketTypes.AnyAsync())
            {
                var events = await _context.Events.ToListAsync();

                await _context.TicketTypes.AddRangeAsync(new[]
                {
                    new TicketType { EventId = events[0].Id, Name = "Standard", Price = 30, Quantity = 500 },
                    new TicketType { EventId = events[0].Id, Name = "VIP", Price = 60, Quantity = 100 },
                    new TicketType { EventId = events[1].Id, Name = "Standard", Price = 20, Quantity = 10000 },
                    new TicketType { EventId = events[2].Id, Name = "Standard", Price = 15, Quantity = 400 },
                    new TicketType { EventId = events[3].Id, Name = "Standard", Price = 18, Quantity = 12000 },
                    new TicketType { EventId = events[4].Id, Name = "Standard", Price = 25, Quantity = 800 },
                    new TicketType { EventId = events[4].Id, Name = "VIP", Price = 50, Quantity = 200 },
                    new TicketType { EventId = events[5].Id, Name = "Standard", Price = 12, Quantity = 350 },
                    new TicketType { EventId = events[6].Id, Name = "Student", Price = 40, Quantity = 200 },
                    new TicketType { EventId = events[6].Id, Name = "Regular", Price = 100, Quantity = 300 },
                    new TicketType { EventId = events[6].Id, Name = "VIP", Price = 200, Quantity = 100 },
                    new TicketType { EventId = events[7].Id, Name = "Standard", Price = 10, Quantity = 5000 },
                    new TicketType { EventId = events[7].Id, Name = "Premium", Price = 25, Quantity = 1000 },
                    new TicketType { EventId = events[8].Id, Name = "General", Price = 20, Quantity = 3000 }
                });
                await _context.SaveChangesAsync();
            }

            //---------------------------------------------------
            // 9. ORDERS + DETAILS + TICKETS
            //---------------------------------------------------
            if (!await _context.Orders.AnyAsync())
            {
                var client = await _context.Users.FirstAsync(u => u.Username == "client1");
                var ticketType = await _context.TicketTypes.OrderBy(tt => tt.Id).Skip(13).FirstAsync();

                var order = new Order
                {
                    OrderDate = new DateTime(2025, 9, 5, 14, 20, 0),
                    TotalAmount = 60,
                    UserId = client.Id,
                    StripePaymentIntentId = "pi_demo_123",
                    IsPaid = true,
                    State = "completed"
                };

                await _context.Orders.AddAsync(order);
                await _context.SaveChangesAsync();

                var orderDetail = new OrderDetail
                {
                    OrderId = order.Id,
                    TicketTypeId = ticketType.Id,
                    Quantity = 3,
                    UnitPrice = 20,
                    TotalPrice = 60
                };

                await _context.OrderDetails.AddAsync(orderDetail);
                await _context.SaveChangesAsync();

                await _context.Tickets.AddRangeAsync(
                    new Ticket { QRCode = "QR001", State = "used", OrderDetailId = orderDetail.Id },
                    new Ticket { QRCode = "QR002", State = "used", OrderDetailId = orderDetail.Id },
                    new Ticket { QRCode = "QR003", State = "used", OrderDetailId = orderDetail.Id }
                );
                await _context.SaveChangesAsync();
            }

            return Ok("Database seeded successfully.");
        }
    }
}
