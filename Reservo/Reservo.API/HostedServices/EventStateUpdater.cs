using Reservo.Services.Interfaces;

namespace Reservo.API.HostedServices
{
    public class EventStateUpdater : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;

        public EventStateUpdater(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {

            while (!stoppingToken.IsCancellationRequested)
            {
                using var scope = _serviceProvider.CreateScope();
                var eventService = scope.ServiceProvider.GetRequiredService<IEventService>();

                await eventService.CompleteExpiredEventsAsync();
                
                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
            }
        }
    }
}
