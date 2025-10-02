using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace Reservo.Model.Entities
{
    public class UserProfile
    {
        [Key]
        [ForeignKey("User")] 
        public int UserId { get; set; }
        public User User { get; set; } = null!;
        public string VectorJson { get; set; } = "";

        [NotMapped] 
        public float[] Vector
        {
            get => string.IsNullOrEmpty(VectorJson)
                   ? Array.Empty<float>()
                   : JsonSerializer.Deserialize<float[]>(VectorJson)!;

            set => VectorJson = JsonSerializer.Serialize(value);
        }

    }
}
