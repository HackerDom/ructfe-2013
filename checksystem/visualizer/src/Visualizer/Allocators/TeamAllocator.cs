#region

using System;
using System.Collections.Generic;
using System.Windows;

#endregion

namespace Visualizer {
    public abstract class TeamAllocator : ITeamAllocator {
        protected int count;

        protected IEnumerator <Point> enumerator;
        protected double height;
        protected IList <Point> points;
        protected double size;
        protected double width;

        protected TeamAllocator () {
            this.width = 0;
            this.height = 0;
            this.size = 0;
            this.count = 0;
        }

        #region ITeamAllocator Members

        public void Initialize (double width, double height, double size, int count) {
            this.width = width;
            this.height = height;
            this.size = size;
            this.count = count;

            this.points = new List <Point> ();

            this.AllocateAll ();

            this.enumerator = this.points.GetEnumerator ();
            this.enumerator.Reset ();
        }

        public Point AllocateNewPoint () {
            if (!this.enumerator.MoveNext ())
                throw new ArgumentOutOfRangeException ();

            return this.enumerator.Current;
        }

        public abstract string Name { get; }

        #endregion

        protected abstract void AllocateAll ();
    }
}