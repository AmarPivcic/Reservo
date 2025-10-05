using Microsoft.ML;
using Reservo.Model.DTOs.Event;
using Reservo.Services.Interfaces;
using Reservo.Model.Entities;
using System.Text.Json;

namespace Reservo.Services.Services
{
    public class EventVectorizerService : IEventVectorizerService
    {
        private readonly MLContext _mlContext;
        private readonly IEventService _eventService;
        private readonly IEventVectorService _eventVectorService;

        public EventVectorizerService(IEventService eventService, IEventVectorService eventVectorService)
        {
            _mlContext = new MLContext();
            _eventService = eventService;
            _eventVectorService = eventVectorService;
        }

        public async Task TrainAndStoreEventVectors()
        {
            var events = await _eventService.GetAllEvents();

            var data = _mlContext.Data.LoadFromEnumerable(events.Select(ev =>
                new EventDataDTO
                {
                    EventId = ev.Id,
                    Features = $"{ev.Name} {ev.Category?.Name} {ev.Description} {ev.Venue?.City.Name}"
                }));

            var pipeline = _mlContext.Transforms.Text.FeaturizeText(
                outputColumnName: "FeaturesVector",
                inputColumnName: nameof(EventDataDTO.Features));

            var model = pipeline.Fit(data);

            var transformed = model.Transform(data);
            var vectors = _mlContext.Data
                .CreateEnumerable<EventVectorRow>(transformed, reuseRowObject: false)
                .ToList();

            foreach (var ev in events)
            {
                var vectorRow = vectors.First(v => v.EventId == ev.Id);

                var evVector = new EventVector
                {
                    EventId = ev.Id,
                    Vector = vectorRow.FeaturesVector
                };

                await _eventVectorService.UpsertAsync(evVector);
            }

            _mlContext.Model.Save(model, data.Schema, "event_vectorizer.zip");
        }

        private class EventVectorRow
        {
            public int EventId { get; set; }
            public float[] FeaturesVector { get; set; } = Array.Empty<float>();
        }
    }
}
