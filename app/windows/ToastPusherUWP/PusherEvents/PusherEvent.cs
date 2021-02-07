﻿using Newtonsoft.Json;
using System;
using System.Diagnostics;

namespace ToastPusherUWP
{
    public class PusherEvent
    {
        public PusherEvent(string channel, string eventName, PusherEventData eventData)
        {
            Channel = channel;
            EventName = eventName;
            EventData = eventData;
        }

        public string Channel { get; }
        public string EventName { get; }
        public PusherEventData EventData { get;  }

        public override string ToString() => $"({Channel}, {EventName}, {EventData.Message})";

        static public PusherEvent From(PusherClient.PusherEvent pusherClientEvent)
        {
            PusherEventData data;
            try
            {
                data = JsonConvert.DeserializeObject<PusherEventData>(pusherClientEvent.Data);
            }
            catch (JsonException e)
            {
                Debug.WriteLine(e.Message);
                data = new PusherEventData(pusherClientEvent.Data);
            }
            return new PusherEvent(pusherClientEvent.ChannelName, pusherClientEvent.EventName, data);
        }
    }

    public class PusherEventData
    {
        public PusherEventData(string message)
        {
            Message = message;
        }

        [JsonProperty(PropertyName= "message", Required = Required.Always)]
        public string Message { get; }
    }
}