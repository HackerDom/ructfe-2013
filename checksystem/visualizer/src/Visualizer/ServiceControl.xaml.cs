#region

using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using Visualizer.Resources;

#endregion

namespace Visualizer {
    public partial class ServiceControl {
        private Point ? _center;

        private TextBlock serviceState;
        private TextBlock tooltipText;

        public ServiceControl (string serviceName) {
            this.InitializeComponent ();

            this.ServiceState = new ServiceState (ServiceStateCode.STATE_DOWN, string.Empty);
            this.ServiceName = serviceName;

            this.ChangeState (this.ServiceState);

            this.AttachTooltip ();
        }

        private void AttachTooltip () {
            var tooltipContent = new StackPanel ();

            var tooltipCaption = new TextBlock {
                                                   Text = this.ServiceName,
                                                   TextAlignment = TextAlignment.Center,
                                                   FontSize = 11,
                                                   Foreground = new SolidColorBrush (Color.FromArgb (0xFF, 0xFF, 0xFF, 0xFF))
                                               };
            
            this.tooltipText = new TextBlock {
                Text = string.Empty,
                TextWrapping = TextWrapping.Wrap
            };

            this.serviceState = new TextBlock {
                Text = string.Format ("{0} {1}", LocalizedStrings.ServiceStatus, ServiceStateCodeClassifier.FriendlyNamed (this.ServiceState.Code)),
                TextWrapping = TextWrapping.Wrap
            };

            tooltipContent.Children.Add (new Border {
                Background = new SolidColorBrush (Color.FromArgb (0xFF, 0x65, 0x88, 0xB7)),
                CornerRadius = new CornerRadius (4, 4, 0, 0),
                Child = tooltipCaption
            });

            tooltipContent.Children.Add (this.serviceState);
            tooltipContent.Children.Add (this.tooltipText);

            ToolTipService.SetToolTip (this, new ToolTip {
                                                             Template = this.Resources ["TooltipTemplate"] as ControlTemplate,
                                                             Content = tooltipContent
                                                         });
        }

        public ServiceState ServiceState { get; private set; }

        public string ServiceName { get; private set; }

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

        public void SetLocation (Point center, Size windowSize) {
            this._center = center;

            this.Margin = new Thickness (center.X - this.LayoutRoot.Width / 2,
                                         center.Y - this.LayoutRoot.Height / 2,
                                         windowSize.Width - (center.X + this.LayoutRoot.Width / 2),
                                         windowSize.Height - (center.Y + this.LayoutRoot.Height / 2));
        }

        private void PrepareTransform (Color start, Color stop, double size) {
            this.StateTransformStartColor.To = start;
            this.StateTransformStopColor.To = stop;
            this.StateTransformWidth.To = size;
            this.StateTransformHeight.To = size;
        }

        public void ChangeState (ServiceStateCode code) {
            this.ChangeState (new ServiceState (code, string.Empty));
        }

        public void ChangeState (ServiceState state) {
            var old = this.ServiceState.Code;
            this.ServiceState = state;

            if (old == state.Code)
                return;

            this.serviceState.Text = string.Format ("{0} {1}", LocalizedStrings.ServiceStatus, ServiceStateCodeClassifier.FriendlyNamed (state.Code));
            this.tooltipText.Text = state.Description;

            switch (state.Code) {
                case ServiceStateCode.STATE_OK :
                    this.PrepareTransform (Color.FromArgb (0xFF, 0x00, 0xFF, 0x00), Color.FromArgb (0xFF, 0x00, 64, 0x00), 10);
                    break;

                case ServiceStateCode.STATE_NOT_FLAG :
                    this.PrepareTransform (Color.FromArgb (0xFF, 0xFF, 0xFF, 0x00), Color.FromArgb (0xFF, 0x80, 0x80, 0x00), 8);
                    break;

                case ServiceStateCode.STATE_INCORRECT :
                    this.PrepareTransform (Color.FromArgb (0xFF, 0xDF, 0xF4, 0xFF), Color.FromArgb (0xFF, 0x00, 0x51, 0x77), 8);
                    break;

                case ServiceStateCode.STATE_DOWN :
                    this.PrepareTransform (Color.FromArgb (0xFF, 0xC4, 0xC4, 0xC4), Color.FromArgb (0xFF, 0x20, 0x20, 0x20), 6);
                    break;

                case ServiceStateCode.CHECKER_ERROR:
                    this.PrepareTransform (Color.FromArgb (0xFF, 0x00, 0x00, 0x00), Color.FromArgb (0xFF, 0x00, 0x00, 0x00), 8);
                    break;

                default :
                    this.PrepareTransform (Color.FromArgb (0xFF, 0xC4, 0xC4, 0xC4), Color.FromArgb (0xFF, 0x20, 0x20, 0x20), 8);
                    break;
            }

            this.StateTransform.Begin ();
        }

        private void StopShieldTransforms () {
            this.ShieldRestoreTransform.Stop ();
            this.ShieldResetTransform.Stop ();
        }

        public void RenderAttack () {
            this.StopShieldTransforms ();
            this.ShieldResetTransform.Begin ();
        }

        public void Restore () {
            this.StopShieldTransforms ();
            this.ShieldRestoreTransform.Begin ();
        }
    }
}