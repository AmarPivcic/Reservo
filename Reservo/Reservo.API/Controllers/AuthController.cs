using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.User;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class AuthController : ControllerBase
    {
        protected readonly ILogger<AuthController> _logger;
        protected readonly IAuthService _service;

        public AuthController(IAuthService service, ILogger<AuthController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] UserLoginDTO request)
        {

            var token = await _service.Login(request);

            if (token == null)
            {
                throw new UserException("Incorrect login!");
            }

            return Ok(new { token });
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            var token = Request.Headers["Authorizations"].ToString().Split(" ").Last();
            await _service.RevokeToken(token);
            return Ok(new { message = "Logout successful." });
        }
    }
}
