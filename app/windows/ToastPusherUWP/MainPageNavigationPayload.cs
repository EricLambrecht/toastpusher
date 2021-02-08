using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ToastPusherUWP
{
    public class MainPageNavigationPayload<T>
    {
        public MainPage MainPageReference;
        public T Parameter;
        public MainPageNavigationPayload(MainPage reference, T parameter) 
        {
            MainPageReference = reference;
            Parameter = parameter;
        }
    }
}
