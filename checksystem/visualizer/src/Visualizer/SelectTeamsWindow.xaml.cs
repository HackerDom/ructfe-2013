#region

using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using Visualizer.Resources;

#endregion

namespace Visualizer {
    public partial class SelectTeamsWindow {
        private readonly TeamCollection teams;

        internal SelectTeamsWindow (TeamCollection teams) {
            this.InitializeComponent ();

            this.Title = LocalizedStrings.TeamsFilterWindow;

            this.teams = teams;

            var all = new List <Team> (this.teams.All);
            for (var i = 0; i < all.Count; ++ i) {
                this.NotShowedList.Items.Add (new ListBoxItem {
                                                                  Content = all [i].Name,
                                                                  Visibility = this.teams [i] != null ? Visibility.Collapsed : Visibility.Visible
                                                              });

                this.ShowedList.Items.Add (new ListBoxItem {
                                                               Content = all [i].Name,
                                                               Visibility = this.teams [i] == null ? Visibility.Collapsed : Visibility.Visible
                                                           });
            }
        }

        private void OKButton_Click (object sender, RoutedEventArgs e) {
            for (var i = 0; i < this.teams.Length; ++ i)
                this.teams.ApplyFilter (i, (this.ShowedList.Items [i] as ListBoxItem).Visibility == Visibility.Visible);

            this.DialogResult = true;
        }

        private void CancelButton_Click (object sender, RoutedEventArgs e) {
            this.DialogResult = false;
        }

        private void ShowAll_Click (object sender, RoutedEventArgs e) {
            foreach (ListBoxItem item in this.NotShowedList.Items)
                item.Visibility = Visibility.Collapsed;

            foreach (ListBoxItem item in this.ShowedList.Items)
                item.Visibility = Visibility.Visible;
        }

        private void ShowSelected_Click (object sender, RoutedEventArgs e) {
            var idx = this.NotShowedList.SelectedIndex;

            if (idx == -1)
                return;

            (this.NotShowedList.Items [idx] as ListBoxItem).Visibility = Visibility.Collapsed;
            (this.ShowedList.Items [idx] as ListBoxItem).Visibility = Visibility.Visible;
        }

        private void HideSelected_Click (object sender, RoutedEventArgs e) {
            var idx = this.ShowedList.SelectedIndex;

            if (idx == -1)
                return;

            (this.NotShowedList.Items [idx] as ListBoxItem).Visibility = Visibility.Visible;
            (this.ShowedList.Items [idx] as ListBoxItem).Visibility = Visibility.Collapsed;
        }

        private void HideAll_Click (object sender, RoutedEventArgs e) {
            foreach (ListBoxItem item in this.NotShowedList.Items)
                item.Visibility = Visibility.Visible;

            foreach (ListBoxItem item in this.ShowedList.Items)
                item.Visibility = Visibility.Collapsed;
        }
    }
}