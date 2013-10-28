#region

using System.Windows;

#endregion

namespace Visualizer {
    public interface ITeamAllocator {
        string Name { get; }
        void Initialize (double width, double height, double size, int count);
        Point AllocateNewPoint ();
    }
}