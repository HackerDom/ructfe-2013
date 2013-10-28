#region

using System;
using System.Windows;
using Visualizer.Resources;

#endregion

namespace Visualizer {
    public sealed class CircleAllocator : TeamAllocator {
        public override string Name {
            get { return LocalizedStrings.CircleAllocation; }
        }

        private static Point2D CirclePoint (double radius, double phi) {
            return new Point2D (radius * Math.Cos (phi), radius * Math.Sin (phi));
        }

        private void Allocate (Point2D center, double radius, int N) {
            if (N <= 0)
                return;

            if (radius <= 0)
                return;

            var phi = 2 * Math.Atan (this.size / (2 * radius));
            var n = (int) (2 * Math.PI / phi);

            if (N < n)
                n = N;

            phi = 2 * Math.PI / n;

            var phi_0 = 0.0;
            for (var i = 0; i < n; ++ i) {
                this.points.Add (center + CirclePoint (radius, phi_0));
                phi_0 += phi;
            }

            this.Allocate (center, radius - this.size, N - n);
        }

        protected override void AllocateAll () {
            var center = new Point (this.width / 2, this.height / 2);

            this.Allocate (new Point2D (center), Math.Min (this.width, this.height) / 2 - this.size / 2, this.count);
        }
    }
}