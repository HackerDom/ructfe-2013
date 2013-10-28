#region

using System;

#endregion

namespace Visualizer {
    public sealed class AddScoresEvent : MonitorEventBase {
        #region Types enum

        public enum Types {
            ATTACK,
            DEFENCE,
            ADVISORY,
            TASK
        }

        #endregion

        public AddScoresEvent (Types type, string str) {
            var data = str.Trim ().Split (new [] { ' ' });

            this.Time = VisualizerDateTime.Parse (data [1]);

            this.Team = int.Parse (data [2]) - 1;

            var delta = int.Parse (data [3]);

            switch (type) {
                case Types.ATTACK :
                    this.InitDelta (delta, 0, 0, 0);
                    break;

                case Types.DEFENCE :
                    this.InitDelta (0, delta, 0, 0);
                    break;

                case Types.ADVISORY :
                    this.InitDelta (0, 0, delta, 0);
                    break;

                case Types.TASK :
                    this.InitDelta (0, 0, 0, delta);
                    break;
            }
        }

        public int DeltaAttack { get; private set; }

        public int DeltaDefence { get; private set; }

        public int DeltaAdvisory { get; private set; }

        public int DeltaTask { get; private set; }

        public int Team { get; private set; }

        public override DateTime Time { get; protected set; }

        private void InitDelta (int attack, int defence, int advisory, int task) {
            this.DeltaAttack = attack;
            this.DeltaDefence = defence;
            this.DeltaAdvisory = advisory;
            this.DeltaTask = task;
        }
    }
}