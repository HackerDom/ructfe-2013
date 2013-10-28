#region

using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using Visualizer.Resources;

#endregion

namespace Visualizer {
    public partial class TeamControl {
        private Point ? _center;
        private int hilite_index;
        
        private ProgressBar total_scores;
        private ProgressBar attack_scores;
        private ProgressBar defence_scores;
        private ProgressBar advisory_scores;
        private ProgressBar tasks_scores;

        public TeamControl (string teamName) {
            this.InitializeComponent ();

            this.TeamName = teamName;
            this._center = null;
            this.hilite_index = 0;

            this.AttachTooltip ();
        }

        private void AttachTooltip () {
            var tooltipContent = new StackPanel { Width = 150, UseLayoutRounding = true };

            var tooltipCaption = new TextBlock {
                                                   Height = 16,
                                                   Text = this.TeamName,
                                                   TextAlignment = TextAlignment.Center,
                                                   FontSize = 11,
                                                   Foreground = new SolidColorBrush (Color.FromArgb (0xFF, 0xFF, 0xFF, 0xFF))
                                               };

            var grid = new Grid ();

            grid.ColumnDefinitions.Add (new ColumnDefinition { Width = GridLength.Auto });
            grid.ColumnDefinitions.Add (new ColumnDefinition ());
            grid.RowDefinitions.Add (new RowDefinition { Height = new GridLength (16) });
            grid.RowDefinitions.Add (new RowDefinition { Height = new GridLength (16) });
            grid.RowDefinitions.Add (new RowDefinition { Height = new GridLength (16) });
            grid.RowDefinitions.Add (new RowDefinition { Height = new GridLength (16) });
            grid.RowDefinitions.Add (new RowDefinition { Height = new GridLength (16) });

            AddElementToGrid (new TextBlock { Text = LocalizedStrings.TotalProgressBar, FontSize = 11 }, grid, 0, 0);
            AddElementToGrid (new TextBlock { Text = LocalizedStrings.AttackProgressBar, FontSize = 11 }, grid, 1, 0);
            AddElementToGrid (new TextBlock { Text = LocalizedStrings.DefenceProgressBar, FontSize = 11 }, grid, 2, 0);
            AddElementToGrid (new TextBlock { Text = LocalizedStrings.AdvisoryProgressBar, FontSize = 11 }, grid, 3, 0);
            AddElementToGrid (new TextBlock { Text = LocalizedStrings.TasksProgressBar, FontSize = 11 }, grid, 4, 0);

            AddElementToGrid (this.total_scores = new ProgressBar {
                Background = new SolidColorBrush (Color.FromArgb (0xFF, 0xFF, 0xFF, 0xFF)),
                BorderBrush = new SolidColorBrush (Color.FromArgb (0xFF, 0xAD, 0xE3, 0x16)),
                BorderThickness = new Thickness (1),
                Foreground = new SolidColorBrush (Color.FromArgb (0xFF, 0x1A, 0xA9, 0x41)),
                Margin = new Thickness (1),
                Height = 14
            }, grid, 0, 1);

            AddElementToGrid (this.attack_scores = new ProgressBar {
                Background = new SolidColorBrush (Color.FromArgb (0xFF, 0xFF, 0xFF, 0xFF)),
                BorderBrush = new SolidColorBrush (Color.FromArgb (0xFF, 0xAD, 0xE3, 0x16)),
                BorderThickness = new Thickness (1),
                Foreground = new SolidColorBrush (Color.FromArgb (0xFF, 0x1A, 0xA9, 0x41)),
                Margin = new Thickness (1),
                Height = 14
            }, grid, 1, 1);

            AddElementToGrid (this.defence_scores = new ProgressBar {
                Background = new SolidColorBrush (Color.FromArgb (0xFF, 0xFF, 0xFF, 0xFF)),
                BorderBrush = new SolidColorBrush (Color.FromArgb (0xFF, 0xAD, 0xE3, 0x16)),
                BorderThickness = new Thickness (1),
                Foreground = new SolidColorBrush (Color.FromArgb (0xFF, 0x1A, 0xA9, 0x41)),
                Margin = new Thickness (1),
                Height = 14
            }, grid, 2, 1);

            AddElementToGrid (this.advisory_scores = new ProgressBar {
                Background = new SolidColorBrush (Color.FromArgb (0xFF, 0xFF, 0xFF, 0xFF)),
                BorderBrush = new SolidColorBrush (Color.FromArgb (0xFF, 0xAD, 0xE3, 0x16)),
                BorderThickness = new Thickness (1),
                Foreground = new SolidColorBrush (Color.FromArgb (0xFF, 0x1A, 0xA9, 0x41)),
                Margin = new Thickness (1),
                Height = 14
            }, grid, 3, 1);

            AddElementToGrid (this.tasks_scores = new ProgressBar {
                Background = new SolidColorBrush (Color.FromArgb (0xFF, 0xFF, 0xFF, 0xFF)),
                BorderBrush = new SolidColorBrush (Color.FromArgb (0xFF, 0xAD, 0xE3, 0x16)),
                BorderThickness = new Thickness (1),
                Foreground = new SolidColorBrush (Color.FromArgb (0xFF, 0x1A, 0xA9, 0x41)),
                Margin = new Thickness (1),
                Height = 14
            }, grid, 4, 1);


            tooltipContent.Children.Add (new Border {
                Background = new SolidColorBrush (Color.FromArgb (0xFF, 0x65, 0x88, 0xB7)),
                CornerRadius = new CornerRadius (8, 8, 0, 0),
                Child = tooltipCaption
            });

            tooltipContent.Children.Add (grid);

            ToolTipService.SetToolTip (this, new ToolTip {
                Template = this.Resources ["TooltipTemplate"] as ControlTemplate,
                Content = tooltipContent
            });
        }

        private static void AddElementToGrid (FrameworkElement element, Panel grid, int row, int col) {
            Grid.SetColumn (element, col);
            Grid.SetRow (element, row);
            grid.Children.Add (element);
        }

        public string TeamName { get; private set; }

        public double EllipseDiameter {
            get { return this.LayoutRoot.Width; }
        }

        public Point CenterPoint {
            get {
                if (this._center == null)
                    this._center = new Point (this.LayoutRoot.Width / 2, this.LayoutRoot.Height / 2);

                return (Point) this._center;
            }
        }

        internal void ApplyScores (Team team, IEnumerable <Team> all) {
            if (team.TeamControl != this)
                return;

            this.total_scores.Value = TeamRating.Rating (team, all);
            this.attack_scores.Value = TeamRating.Attack (team, all);
            this.defence_scores.Value = TeamRating.Defence (team, all);
            this.advisory_scores.Value = TeamRating.Advisory (team, all);
            this.tasks_scores.Value = TeamRating.Task (team, all);
        }

        internal void ClearScores () {
            this.total_scores.Value = 0;
            this.attack_scores.Value = 0;
            this.defence_scores.Value = 0;
            this.advisory_scores.Value = 0;
            this.tasks_scores.Value = 0;
        }

        public void SetLocation (Point center, Size windowSize) {
            this._center = center;

            this.Margin = new Thickness (center.X - this.LayoutRoot.Width / 2,
                                         center.Y - this.LayoutRoot.Height / 2,
                                         windowSize.Width - (center.X + this.LayoutRoot.Width / 2),
                                         windowSize.Height - (center.Y + this.LayoutRoot.Height / 2));
        }

        private void hiliteControl (object sender, MouseButtonEventArgs e) {
            this.hilite_index = (this.hilite_index + 1) % BrushClassifier.TeamEllipse.Count;

            this.TeamEllipse.Stroke = BrushClassifier.TeamEllipse.Border [this.hilite_index];
            this.TeamEllipse.Fill = BrushClassifier.TeamEllipse.Fill [this.hilite_index];
        }
    }
}