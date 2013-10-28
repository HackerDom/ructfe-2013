namespace Visualizer {
    public sealed class ServiceState {
        public ServiceState (ServiceStateCode code, string description) {
            this.Code = code;
            this.Description = description;
        }

        public ServiceStateCode Code { get; private set; }

        public string Description { get; private set; }
    }
}