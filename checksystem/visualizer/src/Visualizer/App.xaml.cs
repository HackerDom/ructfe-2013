#region

using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Browser;

#endregion

namespace Visualizer {
    public partial class App {
        public App () {
            this.Startup += this.Application_Startup;
            this.Exit += Application_Exit;
            this.UnhandledException += Application_UnhandledException;

            this.InitializeComponent ();
        }

        private void Application_Startup (object sender, StartupEventArgs e) {
            this.RootVisual = new MainPage ();
        }

        private static void Application_Exit (object sender, EventArgs e) {}

        private static void Application_UnhandledException (object sender, ApplicationUnhandledExceptionEventArgs e) {
            if (Debugger.IsAttached)
                return;
            e.Handled = true;
            Deployment.Current.Dispatcher.BeginInvoke (() => ReportErrorToDOM (e));
        }

        private static void ReportErrorToDOM (ApplicationUnhandledExceptionEventArgs e) {
            try {
                var errorMsg = e.ExceptionObject.Message + e.ExceptionObject.StackTrace;
                errorMsg = errorMsg.Replace ('"', '\'').Replace ("\r\n", @"\n");

                HtmlPage.Window.Eval ("throw new Error(\"Unhandled Error in Silverlight Application " + errorMsg + "\");");
            }
            catch (Exception) {}
        }
    }
}