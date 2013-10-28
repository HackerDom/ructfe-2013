namespace Visualizer {
    internal sealed class Attack {
        public Attack (Team attacker, Team victimTeam, Service victimService, int force) {
            this.Attacker = attacker;
            this.VictimTeam = victimTeam;
            this.VictimService = victimService;
            this.Force = force;
        }

        public Team Attacker { get; private set; }

        public Team VictimTeam { get; private set; }

        public Service VictimService { get; private set; }

        public int Force { get; private set; }
    }
}