#region

using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Shapes;

#endregion

namespace Visualizer {
    internal sealed class AttackCollection {
        private readonly Dictionary <ulong, StoryboardHandler> animations;
        private readonly Grid canvas;
        private readonly object lock_obj;

        private ulong attack_id;

        public AttackCollection (Grid canvas) {
            this.lock_obj = new object ();

            this.canvas = canvas;
            this.attack_id = 0;
            this.animations = new Dictionary <ulong, StoryboardHandler> ();
        }

        public void StopAll () {
            lock (this.lock_obj) {
                while (this.animations.Count > 0) {
                    var @enum = this.animations.GetEnumerator ();
                    @enum.MoveNext ();
                    var next = @enum.Current.Value;

                    next.Storyboard.Stop ();
                    next.StopHandler ();
                }
            }
        }

        public void Add (Team attacker, Service victim, int force) {
            var action = new Attack (attacker, victim.Owner, victim, force);
            var id = this.attack_id++;

            var animation = this.PrepareAnimation (action, id);
            if (animation == null)
                return;

            lock (this.lock_obj) {
                this.animations.Add (id, animation);
                animation.Storyboard.Begin ();
            }
        }

        private StoryboardHandler PrepareAnimation (Attack attack, ulong id) {
            if (attack.VictimService.State.Code != ServiceStateCode.STATE_OK)
                return null;

            attack.Attacker.AddVictim (attack.VictimService);

            var x1 = attack.Attacker.TeamControl.CenterPoint.X;
            var y1 = attack.Attacker.TeamControl.CenterPoint.Y;
            var x2 = attack.VictimService.ServiceControl.CenterPoint.X;
            var y2 = attack.VictimService.ServiceControl.CenterPoint.Y;

            var effect = attack.Force == 1 ? 1 : 2;

            var shape = new LineGeometry {
                                                StartPoint = new Point (x1, y1),
                                                EndPoint = new Point (x2, y2)
                                            };

            var flag_line = new Path {
                                            StrokeThickness = effect,
                                            Stroke = BrushClassifier.Line (new Point (x1, y1), new Point (x2, y2)),
                                            CacheMode = new BitmapCache (),
                                            Data = shape,
                                            Effect = new BlurEffect {
                                                                        Radius = effect
                                                                    }
                                        };

            this.canvas.Children.Add (flag_line);

            var duration = new Duration (TimeSpan.FromSeconds (1.0));
            var opacity_duration = new Duration (TimeSpan.FromSeconds (4.0));

            var storyboard = new Storyboard {
                                                Duration = duration + opacity_duration
                                            };

            var target_animation = new PointAnimation {
                                                            Duration = duration
                                                        };
            storyboard.Children.Add (target_animation);
            Storyboard.SetTarget (target_animation, shape);
            Storyboard.SetTargetProperty (target_animation, new PropertyPath ("EndPoint"));
            target_animation.BeginTime = new TimeSpan (0, 0, 0);
            target_animation.From = new Point (x1, y1);
            target_animation.To = new Point (x2, y2);


            var opacity_animation = new DoubleAnimation {
                                                            Duration = opacity_duration
                                                        };
            storyboard.Children.Add (opacity_animation);
            Storyboard.SetTarget (opacity_animation, flag_line);
            Storyboard.SetTargetProperty (opacity_animation, new PropertyPath ("Opacity"));
            opacity_animation.BeginTime = duration.TimeSpan;
            opacity_animation.From = 1.0;
            opacity_animation.To = 0;

            var result = new StoryboardHandler (
                storyboard,
                () => {
                    this.canvas.Resources.Remove (id.ToString ());

                    lock (this.lock_obj)
                        this.animations.Remove (id);

                    this.canvas.Children.Remove (flag_line);

                    attack.VictimService.ServiceControl.ChangeState (attack.VictimService.State);
                    attack.VictimService.State = attack.VictimService.State;

                    attack.Attacker.RemoveVictim (attack.VictimService);

                    attack.VictimService.ServiceControl.RenderAttack ();
                }
            );

            storyboard.Completed += (o, args) => result.StopHandler ();

            this.canvas.Resources.Add (id.ToString (), storyboard);

            return result;
        }

        #region Nested type: StoryboardHandler

        private sealed class StoryboardHandler {
            public StoryboardHandler (Storyboard storyboard, Action stopHandler) {
                this.Storyboard = storyboard;
                this.StopHandler = stopHandler;
            }

            public Storyboard Storyboard { get; private set; }
            public Action StopHandler { get; private set; }
        }

        #endregion
    }
}