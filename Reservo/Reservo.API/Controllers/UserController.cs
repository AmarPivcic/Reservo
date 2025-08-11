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

        [HttpPost()]
        public async override Task<UserGetDTO> Insert(UserInsertDTO request)
        {
            request.RoleId = 0;
            return await (_service as IUserService).Insert(request);
        }

        [HttpPost("InsertAdmin")]
        public async Task<UserGetDTO> InsertAdmin(UserInsertDTO request)
        {
            request.RoleId = 1;
            return await (_service as IUserService).Insert(request); 
        }

        [HttpPost("InsertClient")]
        public async Task<UserGetDTO> InsertClient(UserInsertDTO request)
        {
            request.RoleId = 2;
            return await (_service as IUserService).Insert(request);
        }

        [HttpPut("UpdateByToken")]
        public async Task<UserGetDTO> UpdateByToken(UserUpdateDTO request)
        {
            string? username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            request.Username = username;
            return await (_service as IUserService).UpdateByToken(request);
        }

        [HttpPut("UpdatePasswordByToken")]
        public async Task UpdatePasswordByToken(UserUpdatePasswordDTO request)
        {
            string? username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            request.Username = username;
            await (_service as IUserService).UpdatePasswordByToken(request);
        }

        [HttpPut("UpdateUsernameByToken")]
        public async Task UpdateUsernameByToken(UserUpdateUsernameDTO request)
        {
            string? username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            request.Username = username;
            await (_service as IUserService).UpdateUsernameByToken(request);
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
    }
}
