// #define ENABLE_SUITE

#region

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Windows;

#endregion

namespace Visualizer {
    internal sealed class BaseMonitor : IEnumerable <IMonitorEvent> {
        private readonly IList <IMonitorEvent> events;
        private readonly object lock_obj;

        private readonly string query_type;
        private readonly WebClient webClient;

        private bool completed;
        private long last_time;
        private long seed;

        public BaseMonitor (string query_type) {
            this.webClient = new WebClient ();
            this.lock_obj = new object ();
            this.completed = true;

            this.seed = 0;
            this.last_time = 0;
            this.query_type = query_type;

            this.events = new List <IMonitorEvent> ();

            this.Url = "http://localhost";

            this.webClient.OpenReadCompleted += this.OpenReadCompleted;
        }

        public IMonitorEvent this [int index] {
            get {
                lock (this.lock_obj)
                    return this.events [index];
            }
        }

        public int Count {
            get {
                lock (this.lock_obj)
                    return this.events.Count;
            }
        }

        public IEnumerable <IMonitorEvent> this [int from, int to] {
            get {
                lock (this.lock_obj)
                    for (var i = from; i < to; ++i)
                        yield return this.events [i];
            }
        }

        public string Url { get; set; }

        #region IEnumerable<IMonitorEvent> Members

        public IEnumerator <IMonitorEvent> GetEnumerator () {
            return this.events.GetEnumerator ();
        }

        IEnumerator IEnumerable.GetEnumerator () {
            return this.GetEnumerator ();
        }

        #endregion

        public void BeginLoadUpdates () {
            lock (this.lock_obj) {
                if (! this.completed)
                    return;

                this.completed = false;
            }

#if ENABLE_SUITE
            var query = string.Format ("../monitor.aspx?filter={0}&time={1}&seed={2}", this.query_type, this.last_time, this.seed);
            this.webClient.OpenReadAsync (new Uri (Application.Current.Host.Source, query));
#else
            var query = string.Format ("log?filter={0}&time={1}&seed={2}", this.query_type, this.last_time, this.seed);
            this.webClient.OpenReadAsync (new Uri (string.Format ("{0}/{1}", this.Url, query)));
#endif
        }

        private void OpenReadCompleted (object obj, OpenReadCompletedEventArgs args) {
            if (args.Error != null) {
                lock (this.lock_obj)
                    this.completed = true;

                return;
            }

            var stream = args.Result;
            using (var streamReader = new StreamReader (stream)) {
                long newSeed;
                if (!long.TryParse (streamReader.ReadLine (), out newSeed))
                    newSeed = this.seed;

                lock (this.lock_obj) {
                    var updates = this.events;

                    if (newSeed != this.seed)
                        this.events.Clear ();

                    while (!streamReader.EndOfStream) {
                        var line = streamReader.ReadLine ();

                        var @event = MonitorEvent.Parse (line);
                        if (@event != null)
                            updates.Add (@event);
                    }
                }

                this.seed = newSeed;
            }

            lock (this.lock_obj) {
                // `+1' is dirty hack for `>' or `>=' make equals to `>'
                if (this.Count > 0)
                    this.last_time = (long) new TimeSpan (this [this.Count - 1].Time.Ticks).TotalMilliseconds + 1;

                this.completed = true;
                if (this.OnCompleted != null)
                    this.OnCompleted (this, new EventArgs ());
            }
        }

        public event EventHandler OnCompleted;
    }
}