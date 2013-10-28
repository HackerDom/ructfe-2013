#region

using System.Windows;

#endregion

namespace Visualizer {
    public sealed class Point2D {
        public Point2D (double x, double y) {
            this.X = x;
            this.Y = y;
        }

        public Point2D (Point point) {
            this.X = point.X;
            this.Y = point.Y;
        }

        public double X { get; private set; }

        public double Y { get; private set; }

        public static Point2D operator + (Point2D left, Point2D right) {
            return new Point2D (left.X + right.X, left.Y + right.Y);
        }

        public static Point2D operator - (Point2D left, Point2D right) {
            return left + (-right);
        }

        public static Point2D operator * (Point2D left, double right) {
            return new Point2D (left.X * right, left.Y * right);
        }

        public static Point2D operator - (Point2D left) {
            return new Point2D (- left.X, - left.Y);
        }

        public static implicit operator Point (Point2D point) {
            return new Point (point.X, point.Y);
        }
    }
}