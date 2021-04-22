using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Shared.Model
{
   public class PolicyResult   {
        public List<Policy> ListOfPolicies { get; set; }
    }
    public class Policy
    {
        public string PolicyNumber { get; set; }
        public string StateName { get; set; }

        [JsonConverter(typeof(UnixDateTimeConverter))]
        public int ProcessStartTimeUtc { get; set; }

        public double AgeInMinutes { get; set; }
    }

}
