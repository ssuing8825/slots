using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.Azure.Cosmos;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Shared.Model;

namespace FunctionProj
{
    public class CosmosDatabase
    {
        /// The Azure Cosmos DB endpoint for running this GetStarted sample.
        private readonly string Endpoint = "https://conversion-cosmosdb.documents.azure.com:443/";
        private readonly string Key = "5yfwvzy1268M27H7JOl05NFNTZWbCbxO8uA7wa5oSTLIg9cOtmZ2OcPSWSdXlx4BKrYFjxogn6oGtbG5nBLsTw==";

        // The Cosmos client instance
        private CosmosClient cosmosClient;

        // The database we will create
        private Database database;

        // The container we will create.
        private Container container;

        // The name of the database and container we will create
        private string databaseId = "ConversionTrackingDb";
        private string containerId = "FlowEvents";

        public CosmosDatabase()
        {
            this.cosmosClient = new CosmosClient(
            Endpoint,
            Key,
            new CosmosClientOptions()
            {
                ApplicationRegion = Regions.EastUS,
            });

            this.database = this.cosmosClient.GetDatabase(databaseId);
            this.container = this.database.GetContainer(containerId);


        }
        public async Task CreateConversionProcess(ConversionProcess conversionProcess)
        {
            await this.container.CreateItemAsync<ConversionProcess>(conversionProcess);
        }

        public async Task UpdateConversionProcess(ConversionProcess conversionProcess)
        {
            var requestOptions = new ItemRequestOptions { IfMatchEtag = conversionProcess.ETag };
            await this.container.ReplaceItemAsync<ConversionProcess>(conversionProcess, conversionProcess.CorrelationId, new PartitionKey(conversionProcess.PolicyNumber), requestOptions);
        }
        public async Task<ConversionProcess> GetConversionProcess(string policyNumber, string correlationId)
        {
            ItemResponse<ConversionProcess> response = await this.container.ReadItemAsync<ConversionProcess>(correlationId, new PartitionKey(policyNumber));

            response.Resource.ETag = response.ETag;
            return response.Resource;

        }

        public async Task<Dictionary<string, int>> GetStateCount()
        {
            var count = new Dictionary<string, int>();

            var iterator = container.GetItemQueryIterator<ConversionStateCounts>("SELECT count(1) as CountOfStates, c.MostRecentState.StateName FROM c where c.IsInFinalState = false GROUP BY c.MostRecentState.StateName");
            while (iterator.HasMoreResults)
            {

                var results = await iterator.ReadNextAsync();
                foreach (var result in results)
                {
                    count.Add(result.StateName, result.CountOfStates);
                  
                }
            }
            return count;
        }
        public async Task<List<Policy>> GetPoliciesOpenLongerThanMinutes(int minutes)
        {
            var policies = new List<Policy>();

            var dateTime = DateTime.UtcNow.AddMinutes(-minutes);
            var dateTimeOffset = new DateTimeOffset(dateTime);
            var unixDateTime = dateTimeOffset.ToUnixTimeSeconds();


        
            var currentunixDateTime = new DateTimeOffset(DateTime.UtcNow).ToUnixTimeSeconds();


            var iterator = container.GetItemQueryIterator<Policy>(string.Format("SELECT c.PolicyNumber, c.MostRecentState.StateName, c.ProcessStartTimeUtc FROM c where c.IsInFinalState = false and  c.ProcessStartTimeUtc < {0}", unixDateTime));
            while (iterator.HasMoreResults)
            {
                var results = await iterator.ReadNextAsync();
                foreach (var result in results)
                {
                    result.AgeInMinutes = (currentunixDateTime - result.ProcessStartTimeUtc)/60;
                    policies.Add(result);
                }
            }
            return policies;
        }

        public async Task CleanAndCreateDatabase()
        {
            this.database = await this.cosmosClient.CreateDatabaseIfNotExistsAsync(databaseId);
            this.container = this.database.GetContainer(containerId);
            await this.container.DeleteContainerAsync();
            this.container = await this.database.CreateContainerIfNotExistsAsync(containerId, "/PolicyNumber");

        }
    }
}
