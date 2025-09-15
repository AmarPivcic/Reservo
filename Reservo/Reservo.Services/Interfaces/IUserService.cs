using Reservo.Model.DTOs.User;
using Reservo.Model.Entities;
using Reservo.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IUserService : IBaseService<User, UserGetDTO, UserInsertDTO, UserUpdateDTO, UserSearchObject>
    {
        Task<UserGetDTO> UpdateByToken(UserUpdateDTO request);
        Task UpdatePasswordByToken(UserUpdatePasswordDTO request);
        Task UpdateUsernameByToken (UserUpdateUsernameDTO request);
        Task UpdateImageByToken(UserUpdateImageDTO request);
        Task ChangeActiveStatus(int id);
        Task<UserGetDTO> GetCurrentUser(int id);
    }
}
