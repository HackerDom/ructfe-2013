#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using Visualizer.Resources;

#endregion

namespace Visualizer {
    public sealed class RectangleAllocator : TeamAllocator {
        public override string Name {
            get { return LocalizedStrings.RectangleAllocation; }
        }

        private void Allocate (Point2D corner, double w, double h, int N) {
            if (w < 0 || h < 0)
                return;

            var N_max = Math.Min (N, (int) (2 * (w + h) / this.size));

            switch (N_max) {
                case 0 :
                    return;

                case 1 :
                    if (w < this.size / 2 || h < this.size)
                        return;

                    this.points.Add (corner + new Point2D (w, h / 2));
                    return;

                case 2 :
                    if (w < 2 * this.size || this.height < this.size)
                        return;

                    this.points.Add (corner + new Point2D (w, h / 2));
                    this.points.Add (corner + new Point2D (0, h / 2));
                    return;
            }

            for (var n = N_max; n > 2; -- n) {
                var l_0 = Math.Max (this.size, 2 * w / n);
                var l_1 = 2 * (w + h) / n;

                if (l_0 > l_1)
                    return;

                while (l_0 < l_1 && Math.Abs (l_0 - l_1) > 1.0) {
                    var l_c = (l_0 + l_1) / 2;
                    var delta_dist2 = DeltaDistance2 (this.PreAlloc (w, h, n, l_c));

                    if (DoubleEquals (delta_dist2, l_c * l_c))
                        l_0 = l_1 = l_c;

                    if (DoubleLess (delta_dist2, l_c * l_c))
                        l_1 = l_c;

                    if (DoubleGreater (delta_dist2, l_c * l_c))
                        l_0 = l_c;
                }

                var _points = this.PreAlloc (w, h, n, l_0);
                if (DoubleLess (DeltaDistance2 (_points), l_0 * l_0))
                    continue;

                foreach (var p in from p in _points
                                  select ((Point) (corner + p)))
                    this.points.Add (p);

                this.Allocate (corner + new Point2D (this.size, this.size), w - 2 * this.size, h - 2 * this.size, N - n);
                break;
            }
        }

        private static double DeltaDistance2 (IEnumerable <Point2D> points) {
            var delta = points.First () - points.Last ();
            return delta.X * delta.X + delta.Y * delta.Y;
        }

        private IEnumerable <Point2D> PreAlloc (double w, double h, int n, double l) {
            var point = new Point2D (w, h / 2);
            var vec = new Point2D (0, -1);
            yield return point;

            for (var i = 0; i < n - 1; ++i) {
                var _point = point + vec * l;

                if (_point.Y < 0 && DoubleEquals (_point.X, w)) {
                    _point = new Point2D (w - Cathetus (l, point.Y), 0);
                    vec = new Point2D (-1, 0);
                }

                if (_point.X < 0 && DoubleEquals (_point.Y, 0)) {
                    _point = new Point2D (0, Cathetus (l, point.X));
                    vec = new Point2D (0, 1);
                }

                if (_point.Y > h && DoubleEquals (_point.X, 0)) {
                    _point = new Point2D (Cathetus (l, h - point.Y), h);
                    vec = new Point2D (1, 0);
                }

                if (_point.X > w && DoubleEquals (_point.Y, h)) {
                    _point = new Point2D (w, h - Cathetus (l, w - point.X));
                    vec = new Point2D (0, -1);
                }

                point = _point;
                yield return point;
            }
        }

        private static double Cathetus (double hypothenuse, double cathetus) {
            return Math.Sqrt (hypothenuse * hypothenuse - cathetus * cathetus);
        }

        private static bool DoubleEquals (double a, double b) {
            return Math.Abs (a - b) < 1e0;
        }

        private static bool DoubleLess (double a, double b) {
            return (b - a > 2e0);
        }

        private static bool DoubleGreater (double a, double b) {
            return DoubleLess (b, a);
        }

        protected override void AllocateAll () {
            this.Allocate (new Point2D (this.size / 2, this.size / 2), this.width - this.size, this.height - this.size, this.count);
        }
    }
}