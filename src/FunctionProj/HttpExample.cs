using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Azure.Cosmos;
using Shared.Model;
using System.Collections.Generic;
using Microsoft.Extensions.Options;
using Shared.Model.Settings;
using Shared.Services;

namespace FunctionProj
{
    public class HttpExample
    {
        private readonly CosmosClient cosmos;
        private readonly CosmosSettings dbSettings;
        private readonly ILogger<HttpExample> logger;

        public HttpExample(
             ILogger<HttpExample> logger,
             ICosmosService cosmosService,
             IOptions<CosmosSettings> dbSettings
        )
        {
            this.cosmos = cosmosService.CosmosClient;
            this.dbSettings = dbSettings.Value;
            this.logger = logger;
        }

        [FunctionName("HttpExample")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            string name = req.Query["name"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            name = name ?? data?.name;

            var cp = new ConversionProcess();
            cp.CorrelationId = Guid.NewGuid().ToString();
            cp.PolicyNumber = name;
            cp.ProcessStartTimeUtc = DateTime.UtcNow;
            cp.ConversionStates = new List<ConversionState>();


            var currentState = new ConversionState() { StateName = "ConversionStarted", DateTimeOfStateChangeUtc = DateTime.UtcNow, DurationInMillisecondsBetweenLastStateAndThisState = 0 };
            cp.MostRecentState = currentState;
            cp.ConversionStates.Add(currentState);

            var container = this.cosmos.GetContainer(this.dbSettings.DatabaseName, "FlowEvents");

            ItemResponse<ConversionProcess> conversionProcessResponse = await container.CreateItemAsync<ConversionProcess>(cp);

            log.LogInformation("C# HTTP trigger function processed a request.");

            string responseMessage = string.IsNullOrEmpty(name)
                ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                : $"Hello, {name}. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }
    }
}
