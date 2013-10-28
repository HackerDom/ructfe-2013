#region

using System;
using System.Collections.Generic;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;
using System.Xml;
using Visualizer.Resources;
using ThreadingMonitor = System.Threading.Monitor;

#endregion

namespace Visualizer {
    public partial class MainPage {
        private const string TIME_FORMAT = "{0:D2}:{1:D2}:{2:D2}";

        private readonly AllocatorClassifier allocators;
        private readonly AttackCollection attacks;
        private readonly Object lock_object;
        private readonly Monitor monitor;
        private readonly IList <string> service_names;
        private readonly TeamCollection teams;
        private readonly Size windowSize;

        private DateTime current_time;
        private int events_position;
        private int scores_position;
        private bool playing;
        private bool begin_with_realtime;

        private ulong play_iter;
        private ulong update_interval;

        private bool realtimeMode;
        private int speed;

        public MainPage () {
            this.InitializeComponent ();

            this.teams = new TeamCollection ();
            this.attacks = new AttackCollection (this.LayoutCanvas);
            this.allocators =
                new AllocatorClassifier (new [] {
                                                    typeof (CircleAllocator),
                                                    typeof (RectangleAllocator),
                                                    typeof (GridAllocator)
                                                });
            this.monitor = new Monitor ();
            this.lock_object = new object ();
            this.service_names = new List <string> ();

            this.windowSize = new Size (this.LayoutCanvas.Width, this.LayoutCanvas.Height);

            this.speed = (int) this.speedSlider.Value + 1;
            this.realtimeMode = this.realtime.IsChecked == true;
            this.begin_with_realtime = false;
            this.play_iter = 0;
            this.update_interval = 10;

            foreach (var allocator in this.allocators)
                this.Allocation.Items.Add (allocator.Name);

            this.Allocation.SelectedIndex = this.allocators.Index;
        }

        private void LoadSettings () {
            var webClient = new WebClient ();
            webClient.OpenReadCompleted += (o, args) => {
                                               if (args.Error != null)
                                                   return;

                                               var stream = args.Result;
                                               using (var xmlReader = XmlReader.Create (stream)) {
                                                   xmlReader.ReadToFollowing ("monitor");
                                                   xmlReader.MoveToAttribute ("url");
                                                   this.monitor.Url = xmlReader.Value;
                                                   if (xmlReader.MoveToAttribute ("interval"))
                                                       this.update_interval = ulong.Parse (xmlReader.Value);

                                                   if (xmlReader.ReadToFollowing ("realtime"))
                                                       this.begin_with_realtime = true;
                                               }

                                               this.LoadTeams ();
                                           };
            webClient.OpenReadAsync (new Uri (Application.Current.Host.Source, "../settings.xml"));
        }

        private void LoadTeams () {
            var webClient = new WebClient ();
            webClient.OpenReadCompleted += (o, args) => {
                                               if (args.Error != null)
                                                   return;
                                               var stream = args.Result;
                                               using (var xmlReader = XmlReader.Create (stream)) {
                                                   while (xmlReader.ReadToFollowing ("team")) {
                                                       xmlReader.MoveToAttribute ("name");
                                                       var teamName = xmlReader.Value;

                                                       xmlReader.MoveToAttribute ("logo");
                                                       this.teams.AddTeam (new Team (teamName, xmlReader.Value));
                                                   }
                                               }
                                               this.teams.CommitAll ();
                                               this.PrepareTeams ();
                                               this.LoadServices ();
                                           };
            webClient.OpenReadAsync (new Uri (Application.Current.Host.Source, "../teams.xml"));
        }

        private void LoadServices () {
            var webClient = new WebClient ();
            webClient.OpenReadCompleted += (o, args) => {
                                               if (args.Error != null)
                                                   return;

                                               var stream = args.Result;
                                               using (var xmlReader = XmlReader.Create (stream)) {
                                                   while (xmlReader.ReadToFollowing ("service")) {
                                                       xmlReader.MoveToAttribute ("name");
                                                       this.service_names.Add (xmlReader.Value);
                                                   }
                                               }
                                               this.PrepareServices (this.service_names);

                                               this.DrawControls ();

                                               this.StartVisualization ();
                                           };
            webClient.OpenReadAsync (new Uri (Application.Current.Host.Source, "../services.xml"));
        }

        private void DrawControls () {
            this.allocators.InitiazileAllocators (this.LayoutCanvas.Width, this.LayoutCanvas.Height, /*86*/64, this.teams.Showed);
            
            this.attacks.StopAll ();
            
            foreach (var team in this.teams.All) {
                team.TeamControl.Visibility = Visibility.Collapsed;
                team.Label.Visibility = Visibility.Collapsed;

                foreach (var service in team.Services)
                    service.ServiceControl.Visibility = Visibility.Collapsed;
            }
            
            var _all = new List <Team> (this.teams.All);

            for (var idx = 0; idx < this.teams.Length; ++idx) {
                if (this.teams [idx] == null)
                    continue;

                var team = _all [idx];

                try {
                    var center = this.allocators.Current.AllocateNewPoint ();

                    team.TeamControl.Visibility = Visibility.Visible;
                    team.Label.Visibility = Visibility.Visible;
                    team.TeamControl.SetLocation (center, this.windowSize);
                    var m = team.TeamControl.Margin;
                    team.Label.Margin = new Thickness (m.Left - 100, m.Top - 28, m.Right - 100, 12 + this.windowSize.Height - m.Top);

                    for (var i = 0; i < team.Services.Count; ++i) {
                        var service = team.Services [i];
                        var angle = 1.5 * Math.PI - 2 * Math.PI * i / team.Services.Count;
                        var _center = new Point (center.X + 17 * Math.Cos (angle),
                                                 center.Y + 17 * Math.Sin (angle));

                        service.ServiceControl.SetLocation (_center, this.windowSize);
                        service.ServiceControl.Visibility = team.TeamControl.Visibility;
                    }
                }
                catch {
                    this.teams.ApplyFilter (idx, false);
                }
            }
        }

        private void PrepareServices (IEnumerable <string> names) {
            foreach (var team in this.teams) {
                if (team.TeamControl == null)
                    continue;

                foreach (var name in names) {
                    var uicontrol = new ServiceControl (name) { Visibility = Visibility.Collapsed };

                    uicontrol.SetLocation (new Point (0, 0), this.windowSize);
                    this.LayoutCanvas.Children.Add (uicontrol);

                    team.Services.Add (new Service (name, team) {
                                                                    ServiceControl = uicontrol,
                                                                    State = new ServiceState (ServiceStateCode.STATE_DOWN, string.Empty)
                                                                });
                }
            }
        }

        private void PrepareTeams () {
            foreach (var team in this.teams) {
                try {
                    var uicontrol = new TeamControl (team.Name) { Visibility = Visibility.Collapsed };
                    var label = new TextBlock {
                                                   Text = team.Name,
                                                   FontSize = 10.0,
                                                   TextAlignment = TextAlignment.Center,
                                                   Visibility = Visibility.Collapsed,
                                                   Margin = uicontrol.Margin
                                               };

                    uicontrol.SetLocation (new Point (0, 0), this.windowSize);
                    this.LayoutCanvas.Children.Add (uicontrol);
                    this.LayoutCanvas.Children.Add (label);
                    team.TeamControl = uicontrol;
                    team.Label = label;
                }
                catch {
                    break;
                }
            }
        }

        private void UserControl_Loaded (object sender, RoutedEventArgs e) {
            this.LoadSettings ();
        }

        private void StartVisualization () {
            this.monitor.OnCompleted += (o, a) => {
                this.monitor.OnCompleted = this.Monitor_Completed;
                this.PrepareNotRealtimeMode ();

                if (this.begin_with_realtime) {
                    this.realtime.IsChecked = true;
                    this.realtime_Click (this, null);
                }

                var timer = new DispatcherTimer {
                    Interval = TimeSpan.FromSeconds (1.0)
                };
                timer.Tick += (obj, args) => this.ShowVisualizationIteration ();
                timer.Start ();
            };

            this.monitor.BeginLoadUpdates ();
        }

        private void ShowVisualizationIteration () {
            if (!ThreadingMonitor.TryEnter (this.lock_object))
                return;

            if (this.realtimeMode) {
                if ((this.play_iter ++) % this.update_interval == 0)
                    this.monitor.BeginLoadUpdates ();
            }
            else
                this.ShowNextTimeFrame ();
        }
        
        private void DrawEvent (IMonitorEvent @event) {
            if (@event is GetFlagEvent) {
                var item = @event as GetFlagEvent;
                if (this.teams [item.Team] == null || this.teams [item.From_team] == null)
                    return;

                this.attacks.Add (this.teams [item.Team], this.teams [item.From_team].Services [item.From_service], item.Scores);
            }

            if (@event is CheckServiceEvent) {
                var item = @event as CheckServiceEvent;
                if (this.teams [item.Team] == null)
                    return;
                
                this.teams [item.Team].Services [item.Service].ChangeState (item.State);
            }

            if (@event is AddScoresEvent) {
                var item = @event as AddScoresEvent;
                var team = this.teams [item.Team];
                if (team == null)
                    return;

                team.ApplyAddScoresEvent (item);
                team.TeamControl.ApplyScores (team, this.teams.All);
            }
        }

        private void ShowNextTimeFrame () {
            if (this.playing) {
                if (this.events_position >= this.monitor.Count)
                    this.PlayButton_Click (this.playButton, new RoutedEventArgs ());

                while (this.events_position < this.monitor.Count &&
                       (this.monitor [this.events_position].Time - this.current_time).TotalSeconds <= this.speed) {
                    this.DrawEvent (this.monitor [this.events_position]);

                    ++this.events_position;
                }

                while (this.scores_position < this.monitor.ScoresCount &&
                       (this.monitor.GetScoreEvent (this.scores_position).Time - this.current_time).TotalSeconds <=
                       this.speed) {
                    this.DrawEvent (this.monitor.GetScoreEvent (this.scores_position));

                    ++this.scores_position;
                }

                if (this.events_position <= this.monitor.Count)
                    this.current_time = this.current_time.AddSeconds (this.speed);

                if (this.current_time > this.monitor [this.monitor.Count - 1].Time)
                    this.current_time = this.monitor [this.monitor.Count - 1].Time;

                var delta = this.current_time - this.monitor [0].Time;
                this.currentTimeSlider.Value = delta.TotalSeconds;
                this.SetCurrentTimeText (delta);
            }

            ThreadingMonitor.Exit (this.lock_object);
        }

        private void Monitor_Completed (object obj, EventArgs args) {
            var newItems = this.monitor [this.events_position, this.monitor.Count];
            this.events_position = this.monitor.Count;

            foreach (var item in newItems)
                this.DrawEvent (item);

            var scoresItems = this.monitor.Scores (this.scores_position, this.monitor.ScoresCount);
            this.scores_position = this.monitor.Count;

            foreach (var item in scoresItems)
                this.DrawEvent (item);

            if (this.monitor.Count != 0)
                this.SetCurrentTimeText (this.monitor [this.monitor.Count - 1].Time - this.monitor [0].Time);
            ThreadingMonitor.Exit (this.lock_object);
        }

        private void PlayButton_Click (object sender, RoutedEventArgs e) {
            lock (this.lock_object) {
                if (!this.playing && this.previewStates.IsChecked != true)
                    this.CalculateStates ();
                
                if (!this.playing && this.previewStates.IsChecked == true) {
                    var all = new List<Team> (this.teams.All);

                    for (var i = 0; i < this.scores_position; ++i) {
                        var item = this.monitor.GetScoreEvent (i) as AddScoresEvent;
                        var team = all [item.Team];

                        team.ApplyAddScoresEvent (item);
                    }

                    foreach (var team in this.teams.All)
                        team.TeamControl.ApplyScores (team, all);
                }

                if (this.playFromStart.IsChecked == true && !this.playing)
                    for (var i = 0; i < this.events_position; ++i)
                        if (this.monitor [i] is GetFlagEvent) {
                            var item = this.monitor [i] as GetFlagEvent;
                            if (this.teams [item.Team] == null || this.teams [item.From_team] == null)
                                continue;

                            this.attacks.Add (this.teams [item.Team], this.teams [item.From_team].Services [item.From_service], item.Scores);
                        }

                this.playing = !this.playing;

                (sender as Button).Content = this.playing ? LocalizedStrings.StopButton : LocalizedStrings.StartButton;
            }
        }

        private void PlaySlider_Changed (object sender, RoutedPropertyChangedEventArgs <double> args) {
            lock (this.lock_object)
                if (this.playing || this.realtimeMode)
                    return;

            if (this.monitor.Count == 0)
                return;

            this.current_time = this.monitor [0].Time.AddSeconds ((int) args.NewValue);
            this.SetCurrentTimeText (this.current_time - this.monitor [0].Time);

            if (this.previewStates.IsChecked == true)
                this.CalculateStates ();
        }

        private void CalculateStates () {
            var service_info = new Dictionary <KeyValuePair <int, int>, ModifyablePair <ServiceStateCode, bool>> ();

            var all = new List <Team> (this.teams.All);
            
            for (var team = 0; team < this.teams.Length; ++team) {
                all [team].ResetScores ();
                
                for (var service = 0; service < all [team].Services.Count; ++service)
                    service_info.Add (new KeyValuePair <int, int> (team, service),
                                      new ModifyablePair <ServiceStateCode, bool> (ServiceStateCode.STATE_DOWN, false));
            }
            
            var index = 0;
            while (index < this.monitor.Count && this.monitor [index].Time < this.current_time) {
                var evt = this.monitor [index];

                if (evt is CheckServiceEvent) {
                    var _event = evt as CheckServiceEvent;

                    service_info [new KeyValuePair <int, int> (_event.Team, _event.Service)].Key = _event.State.Code;
                }

                if (evt is GetFlagEvent) {
                    var _event = evt as GetFlagEvent;

                    service_info [new KeyValuePair <int, int> (_event.From_team, _event.From_service)].Value = true;
                }

                if (evt is AddScoresEvent) {
                    var @event = evt as AddScoresEvent;

                    all [@event.Team].ApplyAddScoresEvent (@event);
                }

                ++index;
            }
            
            this.events_position = index;

            index = 0;
            while (index < this.monitor.ScoresCount && this.monitor.GetScoreEvent (index).Time < this.current_time) {
                var evt = this.monitor.GetScoreEvent (index) as AddScoresEvent;
                var team = all [evt.Team];

                team.ApplyAddScoresEvent (evt);
                ++index;
            }

            foreach (var team in all)
                team.TeamControl.ApplyScores (team, all);

            this.scores_position = index;

            for (var team = 0; team < this.teams.Length; ++team) {
                if (this.teams [team] == null)
                    continue;

                for (var service = 0; service < this.teams [team].Services.Count; ++service) {
                    var item_info = service_info [new KeyValuePair <int, int> (team, service)];
                    var _service = this.teams [team].Services [service];
                    if (item_info.Value)
                        _service.ServiceControl.RenderAttack ();
                    else
                        _service.ServiceControl.Restore ();
                    _service.ChangeState (new ServiceState (item_info.Key, string.Empty));
                }
            }
        }
        
        private void SpeedSlider_Changed (object sender, RoutedPropertyChangedEventArgs <double> e) {
            this.speed = (int) e.NewValue + 1;
            this.speedSliderCaption.Text = string.Format ("{0}x", this.speed);
        }

        private void SetCurrentTimeText (TimeSpan time) {
            this.currentTimeCaption.Text = string.Format (TIME_FORMAT, time.Hours, time.Minutes, time.Seconds);
        }

        private void PrepareNotRealtimeMode () {
            this.current_time = (this.monitor.Count > 0) ? this.monitor [0].Time : DateTime.Now;
            this.events_position = 0;
            this.scores_position = 0;

            this.currentTimeSlider.Minimum = 0.0;
            this.currentTimeSlider.Maximum = (this.monitor.Count > 0)
                                                 ? ((this.monitor [this.monitor.Count - 1].Time - this.monitor [0].Time).TotalSeconds)
                                                 : 0.0;
            this.currentTimeSlider.Value = 0.0;
            this.SetCurrentTimeText (new TimeSpan (0, 0, 0, 0));

            this.speedSlider.Value = 0;
            this.speedSliderCaption.Text = "1x";

            this.playButton.Content = LocalizedStrings.StartButton;
            this.playButton.IsEnabled = this.monitor.Count > 0;
            this.playing = false;
        }

        private void PrepareRealtimeMode () {
            var delta = this.monitor.Count > 0 ? (this.monitor [this.monitor.Count - 1].Time - this.monitor [0].Time) : new TimeSpan (0, 0, 0, 0);

            this.currentTimeSlider.Minimum = 0.0;
            this.currentTimeSlider.Maximum = delta.TotalSeconds;
            this.currentTimeSlider.Value = this.currentTimeSlider.Maximum;
            this.current_time = this.monitor.Count > 0 ? this.monitor [this.monitor.Count - 1].Time : DateTime.Now;
            this.SetCurrentTimeText (delta);

            this.CalculateStates ();
            this.events_position = this.monitor.Count;
            this.scores_position = this.monitor.ScoresCount;
        }

        private void realtime_Click (object sender, RoutedEventArgs e) {
            this.realtimeMode = this.realtime.IsChecked == true;

            this.attacks.StopAll ();

            this.playButton.IsEnabled = ! this.realtimeMode;
            this.currentTimeSlider.IsEnabled = ! this.realtimeMode;
            this.speedSlider.IsEnabled = ! this.realtimeMode;
            this.playFromStart.IsEnabled = ! this.realtimeMode;
            this.speedSliderCaption.Visibility = this.realtimeMode ? Visibility.Collapsed : Visibility.Visible;
            this.previewStates.IsEnabled = ! this.realtimeMode;

            if (!this.realtimeMode)
                this.PrepareNotRealtimeMode ();
            else
                this.PrepareRealtimeMode ();
        }

        private void ReallocationHandler (object sender, SelectionChangedEventArgs e) {
            this.allocators.Index = this.Allocation.SelectedIndex;
            this.DrawControls ();
        }

        private void FiltersWindowClosed (object sender, EventArgs e) {
            var window = sender as SelectTeamsWindow;

            if (window.DialogResult == false)
                return;

            this.DrawControls ();
        }

        private void ShowFiltersHandler (object sender, RoutedEventArgs e) {
            var filtersWindow = new SelectTeamsWindow (this.teams);

            filtersWindow.Closed += this.FiltersWindowClosed;
            filtersWindow.Show ();
        }
    }
}
