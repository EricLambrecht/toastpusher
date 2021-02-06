﻿using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Media.Animation;
using Windows.UI.Xaml.Navigation;

// Die Elementvorlage "Leere Seite" wird unter https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x407 dokumentiert.

namespace ToastPusherUWP
{
    /// <summary>
    /// Eine leere Seite, die eigenständig verwendet oder zu der innerhalb eines Rahmens navigiert werden kann.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private readonly PusherEventList _events = new PusherEventList();
        public PusherEventList Events { get { return this._events; } }

        public MainPage()
        {
            this.InitializeComponent();
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            // TODO: This could be pulled from Pusher soon
            Events.Add(new PusherEvent("my_channel", "Event 1", "ABC Printers"));
            Events.Add(new PusherEvent("my_channel", "Event 2", "XYZ Refridgerators"));
            Events.Add(new PusherEvent("my_other_channel", "Special Event", "North Pole Toy Factory Inc."));
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
                    contentFrame.Navigate(typeof(SettingsPage));
                    break;
            }
        }
    }
}
