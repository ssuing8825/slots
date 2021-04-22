using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Shared.Model
{
    public class ConversionProcess
    {
        public ConversionProcess()
        {
            ConversionStates = new List<ConversionState>();
            RollbackSuccessResponses = new List<ConversionRollbackResponse>();
            RollbackFailureResponses = new List<ConversionRollbackResponse>();

            ProcessEndTimeUtc = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        }

        [JsonProperty(PropertyName = "id")]
        public string CorrelationId { get; set; }
        public string PolicyNumber { get; set; }

        [JsonConverter(typeof(UnixDateTimeConverter))]
        public DateTime ProcessStartTimeUtc { get; set; }

        [JsonConverter(typeof(UnixDateTimeConverter))]
        public DateTime ProcessEndTimeUtc { get; set; }

        public double TotalDurationInMilliseconds { get; set; }
        public Boolean IsInFinalState { get; set; }
        public ConversionState MostRecentState { get; set; }
        public List<ConversionState> ConversionStates { get; set; }
        public List<ConversionRollbackResponse> RollbackSuccessResponses { get; set; }

        public List<ConversionRollbackResponse> RollbackFailureResponses { get; set; }
        public string PartnerExceptionMessage { get; set; }
        [JsonIgnore]
        public string ETag { get; set; }
    }
}
