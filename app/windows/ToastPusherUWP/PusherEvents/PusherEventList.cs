using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ToastPusherUWP
{
    public class PusherEventList : ObservableCollection<PusherEvent>
    {
        public PusherEventList() : base()
        {
        }
    }
}
