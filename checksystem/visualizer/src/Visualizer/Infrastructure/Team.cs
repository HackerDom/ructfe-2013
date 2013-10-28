#region

using System;
using System.Collections.Generic;
using System.Windows.Controls;

#endregion

namespace Visualizer {
    internal sealed class Team {
        public Team ()
            : this (null, string.Empty) {}

        public Team (string name, string logo) {
            this.Name = name;
            this.LogoPath = logo;
            this.Services = new List <Service> ();
            this.Victims = new List <Service> ();
            this.TeamControl = null;
            this.TeamLegend = null;
        }

        public string Name { get; private set; }

        public string LogoPath { get; private set; }

        public TeamControl TeamControl { get; set; }

        public TextBlock TeamLegend { get; set; }

        public List <Service> Services { get; private set; }

        public int AttackScores { get; private set; }

        public int DefenceScores { get; private set; }

        public int AdvisoryScores { get; private set; }

        public int TaskScores { get; private set; }

        public IList <Service> Victims { get; private set; }

        public void AddVictim (Service service) {
            if (service.Owner == this)
                return;

            if (this.Victims.Contains (service))
                return;

            this.Victims.Add (service);
        }

        public void RemoveVictim (Service service) {
            this.Victims.Remove (service);
        }

        public void ClearVictims () {
            this.Victims.Clear ();
        }

        public void ResetScores () {
            this.AttackScores = 0;
            this.DefenceScores = 0;
            this.AdvisoryScores = 0;
            this.TaskScores = 0;

            this.TeamControl.ClearScores ();
        }

        public void ApplyAddScoresEvent (AddScoresEvent evt) {
            //if (evt.Team != this.Name)
            //    throw new ArgumentException ();

            this.AttackScores += evt.DeltaAttack;
            this.DefenceScores += evt.DeltaDefence;
            this.AdvisoryScores += evt.DeltaAdvisory;
            this.TaskScores += evt.DeltaTask;
        }
    }
}