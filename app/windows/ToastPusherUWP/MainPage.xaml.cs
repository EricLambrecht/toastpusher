﻿using Newtonsoft.Json;
using PusherClient;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using ToastPusherUWP.PusherEvents;
using Windows.ApplicationModel.ExtendedExecution;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Core;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Animation;
using Windows.UI.Xaml.Navigation;
using Windows.UI.Notifications;
using Microsoft.Toolkit.Uwp.Notifications;
using Windows.ApplicationModel;
using Windows.UI.Popups;

// Die Elementvorlage "Leere Seite" wird unter https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x407 dokumentiert.

namespace ToastPusherUWP
{
    /// <summary>
    /// Eine leere Seite, die eigenständig verwendet oder zu der innerhalb eines Rahmens navigiert werden kann.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private readonly PusherEventList _events = new PusherEventList();
        private readonly PusherEventConfigList _eventConfigs = new PusherEventConfigList();
        private ExtendedExecutionSession pusherEventReceptionSession = null;
        public PusherEventList Events { get { return this._events; } }
        public PusherEventConfigList EventConfigs { get { return this._eventConfigs; } }

        public MainPage()
        {
            this.InitializeComponent();
        }

        async protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            string payload = e.Parameter as string;
            if (!string.IsNullOrEmpty(payload))
            {
                activationText.Text = payload;

                if (payload == "StartupTask")
                {
                    startupTaskStatusText.Text = "Enabled";
                }
            }

            await CheckStartupTaskAccessAsync();

            Debug.WriteLine("Attempting to read config json");
            var configList = await PusherEventConfigManager.LoadConfigFromRoamingFolder();
            foreach (PusherEventConfig item in configList)
            {
                EventConfigs.Add(item);
            }

            // TODO: This could be pulled from Pusher soon
            Events.Add(new PusherEvent("my_channel", "Event 1", new PusherEventData("ABC Printers")));
            Events.Add(new PusherEvent("my_channel", "Event 2", new PusherEventData("XYZ Refridgerators")));
            Events.Add(new PusherEvent("my_other_channel", "Special Event", new PusherEventData("North Pole Toy Factory Inc.")));

            BeginPusherEventReceptionSession();

            contentFrame.Navigate(typeof(EventListPage), Events);
        }

        private void RootNavigationView_ItemInvoked(NavigationView sender, NavigationViewItemInvokedEventArgs args)
        {
            if (args.IsSettingsInvoked)
            {
                contentFrame.Navigate(typeof(SettingsPage));
            }

            switch (args.InvokedItemContainer.Name)
            {
                case "Notifications":
                    contentFrame.Navigate(typeof(EventListPage), Events);
                    break;

                case "Settings":
                    var payload = new MainPageNavigationPayload<PusherEventConfigList>(this, EventConfigs);
                    contentFrame.Navigate(typeof(SettingsPage), payload);
                    break;
            }
        }

        private async void BeginPusherEventReceptionSession()
        {
            // The previous Extended Execution must be closed before a new one can be requested.
            // This code is redundant here because the sample doesn't allow a new extended
            // execution to begin until the previous one ends, but we leave it here for illustration.
            EndPusherEventReceptionSession();

            var newSession = new ExtendedExecutionSession();
            newSession.Reason = ExtendedExecutionReason.Unspecified;
            newSession.Description = "Checking for Pusher events";
            newSession.Revoked += PusherEventReceptionSessionRevoked;
            ExtendedExecutionResult result = await newSession.RequestExtensionAsync();

            switch (result)
            {
                case ExtendedExecutionResult.Allowed:
                    Debug.WriteLine("Extended execution was allowed");
                    foreach (PusherEventConfig config in EventConfigs)
                    {
                        var pusher = new Pusher(config.AppKey, new PusherOptions()
                        {
                            Cluster = config.AppCluster
                        });
                        pusher.ConnectionStateChanged += PusherConnectionStateChanged;
                        pusher.Error += PusherError;
                        ConnectionState connectionState = await pusher.ConnectAsync();
                        Channel myChannel = await pusher.SubscribeAsync(config.ChannelName);
                        myChannel.Bind(config.EventName, async (PusherClient.PusherEvent eventData) =>
                        {
                            await OnPusherEventReceptionAsync(config, eventData);
                        });
                    }
                    pusherEventReceptionSession = newSession;
                    break;

                default:
                case ExtendedExecutionResult.Denied:
                    Debug.WriteLine("Extended execution was denied");
                    newSession.Dispose();
                    break;
            }
        }

        private void PusherConnectionStateChanged(object sender, ConnectionState state)
        {
            Debug.WriteLine("Connection state: " + state.ToString());
            connectionStatusBorder.Background = new SolidColorBrush(Windows.UI.Colors.DarkSeaGreen);
            connectionStatusText.Text = state.ToString();
        }

        private void PusherError(object sender, PusherException error)
        {
            Debug.WriteLine("Pusher Channels Error: " + error.ToString());
            connectionStatusBorder.Background = new SolidColorBrush(Windows.UI.Colors.DarkRed);
            connectionStatusText.Text = "Error: " + error.ToString();
        }

        private async Task OnPusherEventReceptionAsync(PusherEventConfig config, PusherClient.PusherEvent rawEvent)
        {
            Debug.WriteLine(config.ChannelName);
            Debug.WriteLine(config.EventName);
            var pusherEvent = PusherEvent.From(rawEvent);
            Debug.WriteLine(pusherEvent.EventData.Message);
           
            await Dispatcher.RunAsync(CoreDispatcherPriority.Normal, () =>
            {
                Events.Add(pusherEvent);
            });

            SpawnEventToast(pusherEvent);
        }

        void EndPusherEventReceptionSession()
        {
            if (pusherEventReceptionSession != null)
            {
                pusherEventReceptionSession.Revoked -= PusherEventReceptionSessionRevoked;
                pusherEventReceptionSession.Dispose();
                pusherEventReceptionSession = null;
            }
        }

        private async void PusherEventReceptionSessionRevoked(object sender, ExtendedExecutionRevokedEventArgs args)
        {
            await Dispatcher.RunAsync(CoreDispatcherPriority.Normal, () =>
            {
                switch (args.Reason)
                {
                    case ExtendedExecutionRevokedReason.Resumed:
                        Debug.WriteLine("Extended execution revoked due to returning to foreground");
                        break;

                    case ExtendedExecutionRevokedReason.SystemPolicy:
                        Debug.WriteLine("Extended execution revoked due to system policy");
                        break;
                }

                EndPusherEventReceptionSession();
            });
        }

        private void SpawnEventToast(PusherEvent pusherEvent)
        {
            // Construct the content
            var content = new ToastContentBuilder()
                .AddToastActivationInfo(pusherEvent.EventData.Message, ToastActivationType.Foreground)
                .AddText(pusherEvent.EventData.Headline)
                .AddText(pusherEvent.EventData.Message)
                .GetToastContent();

            // Create the notification
            var notif = new ToastNotification(content.GetXml());

            // And show it!
            ToastNotificationManager.CreateToastNotifier().Show(notif);
        }

        private async Task CheckStartupTaskAccessAsync()
        {
            StartupTask startupTask = await StartupTask.GetAsync("ToastPusherStartupTask");
            startupTaskStatusText.Text = startupTask.State.ToString();
            switch (startupTask.State)
            {
                case StartupTaskState.Disabled:
                    // Task is disabled but can be enabled.
                    StartupTaskState newState = await startupTask.RequestEnableAsync();
                    startupTaskStatusText.Text = newState.ToString();
                    Debug.WriteLine("Request to enable startup, result = {0}", newState);
                    break;
                case StartupTaskState.DisabledByUser:
                    // Task is disabled and user must enable it manually.
                    startupTaskStatusText.Text = "Was actively disabled";
                    break;
                case StartupTaskState.DisabledByPolicy:
                    Debug.WriteLine(
                        "Startup disabled by group policy, or not supported on this device");
                    break;
                case StartupTaskState.Enabled:
                    Debug.WriteLine("Startup is enabled.");
                    break;
            }
        }

        public async Task<StartupTaskState> AskForStartupTaskAccessAsync()
        {
            StartupTask startupTask = await StartupTask.GetAsync("ToastPusherStartupTask");
            startupTaskStatusText.Text = startupTask.State.ToString();
            StartupTaskState newState = await startupTask.RequestEnableAsync();
            switch (startupTask.State)
            {
                case StartupTaskState.DisabledByUser:
                    // Task is disabled and user must enable it manually.
                    var dialog = new MessageDialog(
                        "Since you explicitely disabled launching Toast Pusher on startup, " +
                        "you can now only re-activate it manually via the \"Startup\" tab in Task Manager due " +
                        "to a Windows policy. You will have to restart the app in order to see the changes take effect.",
                        "Startup must be enabled in Task Manager");
                    await dialog.ShowAsync();
                    break;
                case StartupTaskState.DisabledByPolicy:
                    var dialog2 = new MessageDialog(
                         "You cannot activate startup, because it was disabled by a system policy. You will have to ask your administrator to enable it.",
                         "Startup was disabled by policy");
                    await dialog2.ShowAsync();
                    break;
                case StartupTaskState.Enabled:
                    Debug.WriteLine("Startup is already enabled.");
                    break;
            }
            startupTaskStatusText.Text = newState.ToString();
            return startupTask.State;
        }

        public async Task<StartupTaskState> DisableStartupTask()
        {
            StartupTask startupTask = await StartupTask.GetAsync("ToastPusherStartupTask");
            startupTask.Disable();
            Debug.WriteLine("disabled startup task");
            startupTaskStatusText.Text = StartupTaskState.Disabled.ToString();
            return StartupTaskState.Disabled;
        }
    }
}
