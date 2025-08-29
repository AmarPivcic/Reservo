using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;


class Program
{
    static void Main()
    {
        string[] usernames = { "organizer1", "organizer2", "client1" };
        string[] passwords = { "organizer1", "organizer2", "client1" };

        foreach (var i in Enumerable.Range(0, usernames.Length))
        {
            var salt = GenerateSalt();
            var hash = GenerateHash(salt, passwords[i]);
            Console.WriteLine($"{usernames[i]} -> Salt: {salt}, Hash: {hash}");
        }
    }

    public static string GenerateSalt()
    {
        var byteArray = RandomNumberGenerator.GetBytes(16);
        return Convert.ToBase64String(byteArray);
    }

    public static string GenerateHash(string salt, string password)
    {
        byte[] src = Convert.FromBase64String(salt);
        byte[] bytes = Encoding.Unicode.GetBytes(password);
        byte[] dst = new byte[src.Length + bytes.Length];

        System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        using HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
        byte[] inArray = algorithm.ComputeHash(dst);
        return Convert.ToBase64String(inArray);
    }
}