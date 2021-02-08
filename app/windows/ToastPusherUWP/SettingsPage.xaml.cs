using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using ToastPusherUWP.PusherEvents;
using Windows.ApplicationModel;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Popups;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// Die Elementvorlage "Leere Seite" wird unter https://go.microsoft.com/fwlink/?LinkId=234238 dokumentiert.

namespace ToastPusherUWP
{
    /// <summary>
    /// Eine leere Seite, die eigenständig verwendet oder zu der innerhalb eines Rahmens navigiert werden kann.
    /// </summary>
    public sealed partial class SettingsPage : Page
    {
        private MainPage mainPage;

        public SettingsPage()
        {
            this.InitializeComponent();
        }

        protected override async void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            var payload = e.Parameter as MainPageNavigationPayload<PusherEventConfigList>;
            this.mainPage = payload.MainPageReference;
            EventConfigList.ItemsSource = payload.Parameter;
            StartupTask startupTask = await StartupTask.GetAsync("ToastPusherStartupTask");
            toggleSwitch.IsOn = startupTask.State == StartupTaskState.Enabled || startupTask.State == StartupTaskState.EnabledByPolicy;
        }

        private async void ToggleSwitch_Toggled(object sender, RoutedEventArgs e)
        {
            StartupTaskState newState;
            ToggleSwitch toggleSwitch = sender as ToggleSwitch;
            if (toggleSwitch != null)
            {
                if (toggleSwitch.IsOn == true)
                {
                    newState = await this.mainPage.AskForStartupTaskAccessAsync();
                }
                else
                {
                    newState = await this.mainPage.DisableStartupTask();
                }
                toggleSwitch.IsOn = newState == StartupTaskState.Enabled || newState == StartupTaskState.EnabledByPolicy;
            }
        }
    }
}
