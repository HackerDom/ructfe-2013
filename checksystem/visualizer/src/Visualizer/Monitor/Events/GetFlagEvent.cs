#region

using System;

#endregion

namespace Visualizer {
    public sealed class GetFlagEvent : MonitorEventBase {
        public GetFlagEvent (string str) {
            var data = str.Trim ().Split (new [] { ' ' });

            this.Time = VisualizerDateTime.Parse (data [1]);

            this.Team = int.Parse (data [2]) - 1;
            this.From_team = int.Parse (data [3]) - 1;
            this.From_service = int.Parse (data [4]) - 1;
            this.Scores = int.Parse (data [5]);
        }

        public int Team { get; private set; }

        public int From_team { get; private set; }

        public int From_service { get; private set; }

        public int Scores { get; private set; }

        public override DateTime Time { get; protected set; }
    }
}