#region

using System;

#endregion

namespace Visualizer {
    public interface IMonitorEvent : IComparable <IMonitorEvent> {
        DateTime Time { get; }
    }
}