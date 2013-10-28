namespace Visualizer {
    internal sealed class Service {
        public Service () {
            this.Name = null;
        }

        public Service (string name, Team owner) {
            this.Name = name;
            this.Owner = owner;
        }

        public Team Owner { get; private set; }

        public string Name { get; private set; }

        public ServiceControl ServiceControl { get; set; }

        public ServiceState State { get; set; }

        public void ChangeState (ServiceState state) {
            this.ServiceControl.ChangeState (state);
            this.State = state;
        }
    }
}