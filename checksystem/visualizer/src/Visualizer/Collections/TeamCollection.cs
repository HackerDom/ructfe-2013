#region

using System.Collections;
using System.Collections.Generic;

#endregion

namespace Visualizer {
    internal sealed class TeamCollection : IEnumerable <Team> {
        private readonly IList <Team> teams;
        private BitArray filter;
        private int size;

        public TeamCollection (int size = 0) {
            this.size = size;
            this.teams = new List <Team> ();
            this.filter = null;

            if (size != 0)
                this.ApplySettings ();
        }

        public int Length {
            get { return this.teams.Count; }
        }

        public int Showed {
            get {
                if (this.filter == null)
                    return 0;

                var result = 0;

                for (var i = 0; i < this.filter.Count; ++ i)
                    if (this.filter [i])
                        ++ result;

                return result;
            }
        }

        public IEnumerable <Team> All {
            get { return new _All (this.teams); }
        }

        private sealed class _All : IEnumerable <Team> {
            private readonly IEnumerable <Team> collection;

            public _All (IEnumerable<Team> collection) {
                this.collection = collection;
            }

            public IEnumerator <Team> GetEnumerator () {
                return this.collection.GetEnumerator ();
            }

            IEnumerator IEnumerable.GetEnumerator () {
                return this.GetEnumerator ();
            }
        }

        public Team this [int index] {
            get { return this.filter [index] ? this.teams [index] : null; }
        }

        #region IEnumerable<Team> Members

        public IEnumerator <Team> GetEnumerator () {
            for (var i = 0; i < this.size; ++i)
                if (this.filter [i])
                    yield return this.teams [i];
        }

        IEnumerator IEnumerable.GetEnumerator () {
            return this.GetEnumerator ();
        }

        #endregion

        private void ApplySettings () {
            this.filter = new BitArray (this.size);
            this.filter.SetAll (false);
        }

        public void AddTeam (Team team) {
            if (this.teams.Count >= this.size && this.size != 0)
                return;

            this.teams.Add (team);
            if (this.filter != null)
                this.filter [this.teams.Count - 1] = true;
        }

        public void CommitAll () {
            if (this.filter != null)
                return;

            this.size = this.teams.Count;
            this.ApplySettings ();

            for (var i = 0; i < this.size; ++ i)
                this.filter [i] = true;
        }

        public void ApplyFilter (int index, bool value) {
            this.filter [index] = value;
        }
    }
}