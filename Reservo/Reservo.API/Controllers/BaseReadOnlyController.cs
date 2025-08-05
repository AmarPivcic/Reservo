using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    [Authorize]
    [Route("[controller]")]
    public class BaseReadOnlyController<TDb, TGet, TSearch> : ControllerBase where TGet : class where TDb : class where TSearch : BaseSearchObject
    {
        protected readonly IBaseReadOnlyService<TDb, TGet, TSearch> _service;
        protected readonly ILogger<BaseReadOnlyController<TDb, TGet, TSearch>> _logger;

        public BaseReadOnlyController(ILogger<BaseReadOnlyController<TDb, TGet, TSearch>> logger, IBaseReadOnlyService<TDb, TGet, TSearch> service)
        {
            _logger = logger;
            _service = service;
        }

        [HttpGet()]
        public async virtual Task<PagedResult<TGet>> Get([FromQuery] TSearch? search = null)
        {
            return await _service.Get(search);
        }

        [HttpGet("{id}")]
        public async Task<TGet> GetById(int id)
        {
            return await _service.GetById(id);
        }
    }
}
