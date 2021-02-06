using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Windows.Storage;
using Newtonsoft.Json;
using System.Collections.ObjectModel;
using System.Diagnostics;

namespace ToastPusherUWP.PusherEvents
{
    class PusherEventConfigManager
    {
        static readonly string TOAST_PUSHER_EVENT_SETTINGS_FILENAME = "toast_pusher_event_settings.json";

        static async public Task<PusherEventConfigList> LoadConfigFromRoamingFolder()
        {
            var folder = ApplicationData.Current.RoamingFolder;
            var file = await folder.GetFileAsync(TOAST_PUSHER_EVENT_SETTINGS_FILENAME);
            using (var stream = await file.OpenStreamForReadAsync())
            using (var reader = new StreamReader(stream, Encoding.UTF8))
            {
                string json = await reader.ReadToEndAsync();
                var pusherEventConfigList = JsonConvert.DeserializeObject<PusherEventConfigList>(json);
                return pusherEventConfigList;
            }
        }

        static async public Task SaveConfigToRoamingFolder(PusherEventConfigList pusherEventConfigList)
        {
            var folder = ApplicationData.Current.RoamingFolder;
            var file = await folder.CreateFileAsync(TOAST_PUSHER_EVENT_SETTINGS_FILENAME, CreationCollisionOption.ReplaceExisting);
            using (var stream = await file.OpenStreamForWriteAsync())
            using (var writer = new StreamWriter(stream, Encoding.UTF8))
            {
                string json = JsonConvert.SerializeObject(pusherEventConfigList);
                await writer.WriteAsync(json);
                Debug.WriteLine("Wrote config json: " + file.Path);
            }
        }
    }

    public class PusherEventConfigList : ObservableCollection<PusherEventConfig>
    {
        public PusherEventConfigList() : base()
        {
        }
    }

    public class PusherEventConfig
    {
        public string AppKey;
        public string AppCluster;
        public string ChannelName;
        public string EventName;

        public PusherEventConfig(string appKey, string appCluster, string channelName, string eventName)
        {
            AppKey = appKey;
            AppCluster = appCluster;
            ChannelName = channelName;
            EventName = eventName;
        }
    }
}
