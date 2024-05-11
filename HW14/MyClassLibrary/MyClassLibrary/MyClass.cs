using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyClassLibrary
{
    public class Triangle
    {        
        public static string CalculateAreaTriangle(int ax, int ay, int bx, int by, int cx, int cy)
        {
            float ab = (float)Math.Pow(Math.Pow(ax - bx, 2) + Math.Pow(ay - by, 2), 0.5);
            float bc = (float)Math.Pow(Math.Pow(bx - cx, 2) + Math.Pow(by - cy, 2), 0.5);
            float ca = (float)Math.Pow(Math.Pow(cx - ax, 2) + Math.Pow(cy - ay, 2), 0.5);

            float p = ab + bc + ca;
            p /= 2;
            float s = (float)Math.Pow(p * (p - ab) * (p - bc) * (p - ca), 0.5);
            return "Площадь треугольнка = " + s;
        }
    }
}
