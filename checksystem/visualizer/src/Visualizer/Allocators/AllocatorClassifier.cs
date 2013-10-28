#region

using System;
using System.Collections;
using System.Collections.Generic;

#endregion

namespace Visualizer {
    public sealed class AllocatorClassifier : IEnumerable <ITeamAllocator> {
        private readonly IList <ITeamAllocator> allocators;
        private int current;

        public AllocatorClassifier () {
            this.allocators = new List <ITeamAllocator> ();
            this.current = 0;
            this.Initialized = false;
        }

        public AllocatorClassifier (IEnumerable <Type> allocators)
            : this () {
            foreach (var allocator in allocators)
                this.AddAllocator (allocator);
        }

        public bool Initialized { get; private set; }

        public ITeamAllocator this [int index] {
            get { return this.allocators [index]; }
        }

        public int Index {
            get { return this.current; }

            set {
                if (value < 0 || value >= this.Count)
                    throw new ArgumentOutOfRangeException ();

                this.current = value;
            }
        }

        public ITeamAllocator Current {
            get { return this [this.current]; }
        }

        public int Count {
            get { return this.allocators.Count; }
        }

        #region IEnumerable<ITeamAllocator> Members

        public IEnumerator <ITeamAllocator> GetEnumerator () {
            return this.allocators.GetEnumerator ();
        }

        IEnumerator IEnumerable.GetEnumerator () {
            return this.GetEnumerator ();
        }

        #endregion

        public void AddAllocator (Type allocatorType) {
            var instance = allocatorType.GetConstructor (new Type[0]).Invoke (new object [] { }) as ITeamAllocator;
            if (instance == null)
                return;

            instance.Initialize (0, 0, 0, 0);
            this.allocators.Add (instance);
        }

        public void InitiazileAllocators (double width, double height, double size, int count) {
            foreach (var allocator in this.allocators)
                allocator.Initialize (width, height, size, count);

            this.Initialized = true;
        }
    }
}