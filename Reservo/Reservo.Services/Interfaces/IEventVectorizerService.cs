using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Interfaces
{
    public interface IEventVectorizerService
    {
        Task TrainAndStoreEventVectors();
    }
}
