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

namespace FunctionProj
{
    public class HttpExample
    {
        private readonly ILogger _logger;
        private readonly IConfiguration _config;
        private CosmosClient _cosmosClient;

        private Database _database;
        private Container _container;

        public HttpExample(
             ILogger<HttpExample> logger,
             IConfiguration config,
             CosmosClient cosmosClient
        )
        {
            _logger = logger;
            _config = config;
            _cosmosClient = cosmosClient;

            _database = _cosmosClient.GetDatabase("slots");
            _container = _database.GetContainer("FlowEvents");
 

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

            ItemResponse<ConversionProcess> conversionProcessResponse = await this._container.CreateItemAsync<ConversionProcess>(cp);

            log.LogInformation("C# HTTP trigger function processed a request.");

         

            string responseMessage = string.IsNullOrEmpty(name)
                ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                : $"Hello, {name}. This HTTP triggered function executed successfully.";

            return new OkObjectResult(responseMessage);
        }
    }
}
