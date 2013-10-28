#region

using System;
using System.Text;

#endregion

namespace Visualizer {
    public sealed class CheckServiceEvent : MonitorEventBase {
        public CheckServiceEvent (string str) {
            var data = str.Trim ().Split (new [] { ' ' });

            this.Time = VisualizerDateTime.Parse (data [1]);

            this.Team = int.Parse (data [2]) - 1;
            this.Service = int.Parse (data [3]) - 1;

            var description = new StringBuilder ();

            for (var i = 5; i < data.Length; ++i) {
                if (description.Length != 0)
                    description.Append (" ");

                description.Append (data [i]);
            }

            var state = int.Parse (data [4]);
            if (!(state >= 101 && state <= 104))
                state = 105;

            this.State = new ServiceState ((ServiceStateCode) state, description.ToString ());
        }

        public int Team { get; private set; }

        public int Service { get; private set; }

        public ServiceState State { get; private set; }

        public override DateTime Time { get; protected set; }
    }
}