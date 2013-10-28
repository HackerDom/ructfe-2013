namespace Visualizer {
    public sealed class ModifyablePair <TKey, TValue> {
        public ModifyablePair (TKey key, TValue value) {
            this.Key = key;
            this.Value = value;
        }

        public TKey Key { get; set; }

        public TValue Value { get; set; }
    }
}