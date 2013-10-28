#region

using System.Windows;
using Visualizer.Resources;

#endregion

namespace Visualizer {
    public sealed class GridAllocator : TeamAllocator {
        public override string Name {
            get { return LocalizedStrings.GridAllocation; }
        }

        protected override void AllocateAll () {
            if (this.count == 0)
                return;

            var n = (int) (this.height / this.size);
            var m = (int) (this.width / this.size);

            var left = (this.width - m * this.size) / 2;
            var top = (this.height - n * this.size) / 2;

            var index = 0;
            for (var i = 0; i < m; ++ i)
                for (var j = 0; j < n; ++j) {
                    this.points.Add (new Point (left + (i + 0.5) * this.size, top + (j + 0.5) * this.size));

                    if (++index >= this.count)
                        break;
                }
        }
    }
}