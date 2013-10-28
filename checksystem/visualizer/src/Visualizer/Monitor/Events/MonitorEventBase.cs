#region

using System;

#endregion

namespace Visualizer {
    public abstract class MonitorEventBase : IMonitorEvent {
        #region IMonitorEvent Members

        public int CompareTo (IMonitorEvent other) {
            return this.Time.CompareTo (other.Time);
        }

        public abstract DateTime Time { get; protected set; }

        #endregion
    }
}