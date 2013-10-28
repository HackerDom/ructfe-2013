#region

using Visualizer.Resources;

#endregion

namespace Visualizer {
    public sealed class Localization {
        private static readonly LocalizedStrings resource = new LocalizedStrings ();

        public LocalizedStrings LocalizedStrings {
            get { return resource; }
        }
    }
}