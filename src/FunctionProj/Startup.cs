using Microsoft.Azure.Cosmos.Fluent;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Azure.WebJobs.Host.Bindings;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.IO;
using System.Linq;

[assembly: FunctionsStartup(typeof(FunctionProj.Startup))]
namespace FunctionProj
{

    public class Startup : FunctionsStartup
    {
        private IConfigurationRoot Configuration { get; set; }

        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddLogging(loggingBuilder =>
            {
                loggingBuilder.AddFilter(level => true);
            });


            var executionContextOptions = builder.Services.BuildServiceProvider().GetService<IOptions<ExecutionContextOptions>>().Value;
			
			var currentDirectory = executionContextOptions.AppDirectory;
            
            // Get the original configuration provider from the Azure Function
			var configuration = builder.Services.BuildServiceProvider().GetService<IConfiguration>();
			
            // Create a new IConfigurationRoot and add our configuration along with Azure's original configuration 
			this.Configuration = new ConfigurationBuilder()
				.SetBasePath(currentDirectory)
				.AddJsonFile("appsettings.dev.json", optional: false, reloadOnChange: true)
                .AddEnvironmentVariables()
				.Build();

			// Replace the Azure Function configuration with our new one
            var config = (IConfiguration)builder.Services.First(d => d.ServiceType == typeof(IConfiguration)).ImplementationInstance;

            builder.Services.AddSingleton((s) =>
            {
                CosmosClientBuilder cosmosClientBuilder = new CosmosClientBuilder(this.Configuration.GetConnectionString("CosmosDb"));

                return cosmosClientBuilder.WithConnectionModeDirect()
                    .WithApplicationRegion("East US 2")
                    .WithBulkExecution(true)
                    .Build();
            });
        }
    }
}