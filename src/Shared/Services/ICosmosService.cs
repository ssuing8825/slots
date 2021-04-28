using Microsoft.Azure.Cosmos;

namespace Shared.Services
{
  public interface ICosmosService
  {
    /// <summary>the client to use for CosmosDB Operations</summary>
    CosmosClient CosmosClient { get; }
  }
}