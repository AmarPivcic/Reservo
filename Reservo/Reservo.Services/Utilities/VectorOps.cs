using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Reservo.Services.Utilities
{
    public static class VectorOps
    {
        public static float[] Average(float[] v1, float[] v2)
        {
            if (v1.Length != v2.Length)
                throw new ArgumentException("Vectors must be the same length");

            float[] result = new float[v1.Length];
            for (int i = 0; i < v1.Length; i++)
                result[i] = (v1[i] + v2[i]) / 2f;

            return result;
        }

        public static double CosineSimilarity(float[] v1, float[] v2)
        {
            double dot = 0, mag1 = 0, mag2 = 0;
            for (int i = 0; i < v1.Length; i++)
            {
                dot += v1[i] * v2[i];
                mag1 += v1[i] * v1[i];
                mag2 += v2[i] * v2[i];
            }
            return dot / (Math.Sqrt(mag1) * Math.Sqrt(mag2));
        }
    }
}
