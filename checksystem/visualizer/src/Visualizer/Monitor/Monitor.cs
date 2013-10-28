#region

using System;
using System.Collections.Generic;

#endregion

namespace Visualizer {
    public sealed class Monitor {
        private readonly Object lock_obj;
        private readonly Object scores_lock;

        private readonly BaseMonitor scores;
        private readonly BaseMonitor state;

        public EventHandler OnCompleted;

        public Monitor () {
            this.scores = new BaseMonitor ("scores");
            this.state = new BaseMonitor ("state");

            this.lock_obj = new object ();
            this.scores_lock = new object ();

            this.state.OnCompleted += this.state_Completed;
        }

        public string Url {
            get { return this.state.Url; }
            set {
                this.scores.Url = value;
                this.state.Url = value;
            }
        }

        public IMonitorEvent this [int index] {
            get {
                lock (this.lock_obj)
                    return this.state [index];
            }
        }

        public IMonitorEvent GetScoreEvent (int index) {
            lock (this.scores_lock)
                return this.scores [index];
        }

        public int Count {
            get {
                lock (this.lock_obj)
                    return this.state.Count;
            }
        }

        public int ScoresCount {
            get {
                lock (this.scores_lock)
                    return this.scores.Count;
            }
        }

        public IEnumerable <IMonitorEvent> this [int from, int to] {
            get {
                lock (this.lock_obj)
                    return this.state [from, to];
            }
        }

        public IEnumerable <IMonitorEvent> Scores (int from, int to) {
            lock (this.scores_lock)
                return this.scores [from, to];
        }

        public void BeginLoadUpdates () {
            this.scores.BeginLoadUpdates ();
            this.state.BeginLoadUpdates ();
        }

        private void state_Completed (object sender, EventArgs e) {
            lock (this.lock_obj)
                this.OnCompleted (this, new EventArgs ());

            /*
            this.scores.OnCompleted += (o, a) => {
                lock (this.scores_lock)
                    this.OnCompleted (this, new EventArgs ());
            };
            
            this.scores.BeginLoadUpdates ();
            */
        }
    }
}
