namespace ToastPusherUWP
{
    public class PusherEvent
    {
        public PusherEvent(string channel, string eventName, object EventData)
        {
            this.Channel = channel;
            this.EventName = eventName;
            this.EventData = EventData;
        }

        public string Channel { get; }
        public string EventName { get; }
        public object EventData { get;  }

        public override string ToString() => $"({Channel}, {EventName}, {EventData})";
    }
}