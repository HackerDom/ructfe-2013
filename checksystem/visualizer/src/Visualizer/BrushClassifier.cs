#region

using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;

#endregion

namespace Visualizer {
    public static class BrushClassifier {
        public static Brush Legend {
            get { return new SolidColorBrush (Color.FromArgb (255, 0, 0, 0)); }
        }

        public static Brush Line (Point startPoint, Point endPoint) {
            return new LinearGradientBrush {
                                               GradientStops = new GradientStopCollection {
                                                                                              new GradientStop
                                                                                              { Color = Color.FromArgb (255, 0, 196, 0), Offset = 0.0 },
                                                                                              new GradientStop
                                                                                              { Color = Color.FromArgb (255, 0, 196, 0), Offset = 0.5 },
                                                                                              new GradientStop
                                                                                              { Color = Color.FromArgb (255, 196, 0, 0), Offset = 1.0 }
                                                                                          },
                                               StartPoint = startPoint,
                                               EndPoint = endPoint,
                                               MappingMode = BrushMappingMode.Absolute
                                           };
        }

        #region Nested type: TeamEllipse

        public static class TeamEllipse {
            public static IList <Brush> Fill {
                get {
                    return new List <Brush> {
                                                new RadialGradientBrush (
                                                    new GradientStopCollection {
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0x00, 0x00, 0xFF), Offset = 0.0 },
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0x00, 0x00, 0x80), Offset = 1.0 }
                                                                               }
                                                    ),
                                                new RadialGradientBrush (
                                                    new GradientStopCollection {
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0x00, 0x80, 0x00), Offset = 0.0 },
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0x00, 0x40, 0x00), Offset = 1.0 }
                                                                               }
                                                    ),
                                                new RadialGradientBrush (
                                                    new GradientStopCollection {
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0xC4, 0x00, 0x00), Offset = 0.0 },
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0x62, 0x00, 0x00), Offset = 1.0 }
                                                                               }
                                                    ),
                                                new RadialGradientBrush (
                                                    new GradientStopCollection {
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0xFF, 0xC9, 0x0E), Offset = 0.0 },
                                                                                   new GradientStop { Color = Color.FromArgb (0xFF, 0x88, 0x69, 0x00), Offset = 1.0 }
                                                                               }
                                                    )
                                            };
                }
            }

            public static IList <Brush> Border {
                get {
                    return new List <Brush> {
                                                new SolidColorBrush (Color.FromArgb (0x00, 0x00, 0x00, 0x80)),
                                                new SolidColorBrush (Color.FromArgb (0x00, 0x00, 0x40, 0x00)),
                                                new SolidColorBrush (Color.FromArgb (0x00, 0x62, 0x00, 0x00)),
                                                new SolidColorBrush (Color.FromArgb (0x00, 0x88, 0x69, 0x00))
                                            };
                }
            }

            public static int Count {
                get { return Fill.Count; }
            }
        }

        #endregion
    }
}