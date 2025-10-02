using Microsoft.EntityFrameworkCore;
using Reservo.Model.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Database
{
    public partial class ReservoContext : DbContext
    {
        public ReservoContext() { }


        public ReservoContext(DbContextOptions<ReservoContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<AuthToken> AuthTokens { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Event> Events { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderDetail> OrderDetails { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Ticket> Tickets { get; set; }
        public DbSet<TicketType> TicketTypes { get; set; }
        public DbSet<Venue> Venues { get; set; }
        public DbSet<UserProfile> UserProfiles { get; set; }
        public DbSet<EventVector> EventVectors { get; set; }
        public DbSet<VenueCategory> VenueCategories { get; set; }
        public DbSet<VenueRequest> VenueRequests { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Event>()
                .HasOne(e => e.Venue)
                .WithMany()
                .HasForeignKey(e => e.VenueId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Event>()
                .HasOne(e => e.Category)
                .WithMany()
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Event>()
                .HasOne(e => e.User)
                .WithMany()
                .HasForeignKey(e => e.OrganizerId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<VenueCategory>()
                .HasKey(vc => new { vc.VenueId, vc.CategoryId });

            modelBuilder.Entity<VenueCategory>()
                .HasOne(vc => vc.Venue)
                .WithMany(v => v.AllowedCategories)
                .HasForeignKey(vc => vc.VenueId);

            modelBuilder.Entity<VenueCategory>()
                .HasOne(vc => vc.Category)
                .WithMany(c => c.Venues)
                .HasForeignKey(vc => vc.CategoryId);

            modelBuilder.Entity<TicketType>()
                .HasOne(tt => tt.Event)
                .WithMany(e => e.TicketTypes)
                .HasForeignKey(tt => tt.EventId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<OrderDetail>()
                .HasOne(od => od.TicketType)
                .WithMany(tt => tt.OrderDetails)
                .HasForeignKey(od => od.TicketTypeId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Order>()
                .HasMany(o => o.OrderDetails)
                .WithOne(od => od.Order)
                .HasForeignKey(od => od.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Ticket>()
                .HasOne(t => t.OrderDetail)
                .WithMany(od => od.Tickets)
                .HasForeignKey(t => t.OrderDetailId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Order>()
                .HasOne(o => o.User as Client)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Event>()
                .HasOne(e => e.User as Organizer)
                .WithMany(u => u.OrganizedEvents)
                .HasForeignKey(e => e.OrganizerId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Review>(entity =>
            {
                entity.HasKey(r => r.Id);

                entity.Property(r => r.Comment)
                    .HasMaxLength(1000);

                entity.Property(r => r.Rating)
                    .IsRequired();

                entity.Property(r => r.CreatedAt)
                    .IsRequired();

                entity.HasOne(r => r.Event)
                    .WithMany(e => e.Reviews)
                    .HasForeignKey(r => r.EventId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(r => r.User as Client)
                    .WithMany(u => u.ReviewsWritten)
                    .HasForeignKey(r => r.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(r => r.Organizer as Organizer)
                    .WithMany(u => u.ReviewsReceived)
                    .HasForeignKey(r => r.OrganizerId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<UserProfile>()
                .HasOne(up => up.User)
                .WithOne() 
                .HasForeignKey<UserProfile>(up => up.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<EventVector>()
                .HasOne(ev => ev.Event)
                .WithOne()
                .HasForeignKey<EventVector>(ev => ev.EventId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<User>()
                .HasDiscriminator<string>("Discriminator")
                .HasValue<User>("User")
                .HasValue<Client>("Client")
                .HasValue<Organizer>("Organizer")
                .HasValue<Admin>("Admin");


            modelBuilder.Entity<VenueRequest>()
                .HasOne(vr => vr.Organizer)
                .WithMany()
                .HasForeignKey(vr => vr.OrganizerId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
