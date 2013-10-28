#region

using System;

#endregion

namespace Visualizer {
    public static class VisualizerDateTime {
        public static DateTime Parse (string str) {
            return new DateTime (10000 * long.Parse (str));
        }
    }
}