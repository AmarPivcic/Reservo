using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Reservo.Model.DTOs.User;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using Reservo.Model.Utilities;
using Reservo.Services.Interfaces;
using System.Runtime.CompilerServices;
using System.Security.Claims;

namespace Reservo.API.Controllers
{
    [ApiController]
    public class UserController : BaseController<User, UserGetDTO, UserInsertDTO, UserUpdateDTO, UserSearchObject>
    {
        public UserController(IUserService service, ILogger<BaseController<User, UserGetDTO, UserInsertDTO, UserUpdateDTO, UserSearchObject>> logger) :base(service, logger)
        {
        }

        [AllowAnonymous]
        [HttpPost("InsertAdmin")]
        public async Task<IActionResult> InsertAdmin([FromBody] UserInsertDTO request)
        {
            request.RoleId = 1;
            try
            {
                var response = await (_service as IUserService).Insert(request);
                return Ok(response);
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [AllowAnonymous]
        [HttpPost("InsertClient")]
        public async Task<IActionResult> InsertClient([FromBody] UserInsertDTO request)
        {
            request.RoleId = 2;
            request.Active = true;
            try
            {
                var response = await (_service as IUserService).Insert(request);
                return Ok(response);
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [AllowAnonymous]
        [HttpPost("InsertOrganizer")]
        public async Task<IActionResult> InsertOrganizer([FromBody] UserInsertDTO request)
        {
            request.RoleId = 3;
            try
            {
                var response = await (_service as IUserService).Insert(request);
                return Ok(response);
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("UpdateByToken")]
        public async Task<UserGetDTO> UpdateByToken([FromBody]UserUpdateDTO request)
        {
            return await (_service as IUserService).UpdateByToken(request);
        }

        [HttpPut("UpdatePasswordByToken")]
        public async Task<IActionResult> UpdatePasswordByToken([FromBody]UserUpdatePasswordDTO request)
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
            {
                request.userId = userId;
            }

            try
            {
                await (_service as IUserService).UpdatePasswordByToken(request);
                return Ok(new { message = "Password changed successfully." });
            }
            catch (UserException ex)
            {

                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("UpdateUsernameByToken")]
        public async Task UpdateUsernameByToken(UserUpdateUsernameDTO request)
        {
            string? username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            request.Username = username;
            await (_service as IUserService).UpdateUsernameByToken(request);
        }

        [HttpPut("UpdateImageByToken")]
        public async Task UpdateImageByToken(UserUpdateImageDTO request)
        {
            string? username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            request.Username = username;
            await (_service as IUserService).UpdateImageByToken(request);
        }

        [HttpGet("GetByToken")]
        public async Task<PagedResult<UserGetDTO>> GetByToken([FromQuery] UserSearchObject? search = null)
        {
            string? username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            search.UserName = username;
            return await (_service as IUserService).Get(search);
        }

        [HttpPut("ChangeActiveStatus")]
        public async Task ChangeActiveStatus(int id)
        {
            await (_service as IUserService).ChangeActiveStatus(id);
        }

        [HttpGet("GetCurrentUser")]
        public async Task<IActionResult> GetCurrentUser()
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int userId))
                {
                    var user = await (_service as IUserService).GetCurrentUser(userId);
                    return Ok(user);
                }
                return BadRequest(new { message = "User not found!" });
            }
            catch (UserException ex)
            {
                return BadRequest(new { message = ex.Message });
            }

        }
    }
}
