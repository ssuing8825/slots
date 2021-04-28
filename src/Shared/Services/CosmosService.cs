using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Fluent;
using Microsoft.Extensions.Options;
using System;
using Shared.Model.Settings;

namespace Shared.Services
{

    /// <summary>
    /// Service to use for accessing a CosmosClient
    /// Ensures that multiple calls to the "CosmosClient" getter only uses 1 instance
    /// </summary>
    /// <remarks>
    /// This service should be registered as a singleton in DI
    /// </remarks>
    public class CosmosService : ICosmosService
    {
        private readonly string connectionString;
        private readonly Lazy<CosmosClient> lazyClient;

        public CosmosService(IOptions<CosmosSettings> settings)
        {
            this.connectionString = settings.Value.ConnectionString;
            this.lazyClient = new Lazy<CosmosClient>(() => new CosmosClientBuilder(this.connectionString)
            //  .WithSerializerOptions(new CosmosSerializationOptions()
            //  {
            //      PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase
            //  })
             .Build()
            );
        }

        /// <inheritdoc/>
        public CosmosClient CosmosClient => this.lazyClient.Value;
    }
}