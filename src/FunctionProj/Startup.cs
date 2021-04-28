using Microsoft.Azure.Cosmos.Fluent;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Azure.WebJobs.Host.Bindings;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Shared.Model.Settings;
using Shared.Services;
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
            ConfigureAppSettings(builder);
            ConfigureDependencyInjection(builder);
        }

        private static void ConfigureAppSettings(IFunctionsHostBuilder builder)
        {
            builder.Services.AddOptions<CosmosSettings>().Configure<IConfiguration>(
                (settings, config) => config.GetSection("Cosmos").Bind(settings));

        }
         private static void ConfigureDependencyInjection(IFunctionsHostBuilder builder)
    {
                //   builder.Services.AddHttpClient<IEphApiService, EphApiService>();
                //   builder.Services.AddHttpClient<IKitVendorService, GbfService>();
                //   builder.Services.AddHttpClient<IPwnService, PwnService>();
                //   builder.Services.AddHttpClient<IQuanumService, QuanumService>();


      builder.Services
        .AddSingleton<ICosmosService, CosmosService>();
        // .AddSingleton<IGhkoatRepository, GhkoatRepository>()
        // .AddSingleton<IJwtService, JwtService>()
        // .AddSingleton<IOauth2TokenAcquisition, Oauth2TokenAcquisition>()
        // .AddSingleton<IHttpClientExtensionMethodProxy, HttpClientExtensionMethodProxy>();

      // Core Validators
    //   builder.Services
    //     .AddTransient<IValidator<KitOrderRequest>, KitOrderRequestValidator>()
    //     .AddTransient<IValidator<Address>, AddressValidator>()
    //     .AddTransient<IValidator<OrderDetail>, OrderDetailValidator>()
    //     .AddTransient<IValidator<Order>, OrderValidator>()
    //     .AddTransient<IValidator<ParticipantInfo>, ParticipantInfoValidator>()
    //     .AddTransient<IValidator<ShippingPreferences>, ShippingPreferencesValidator>()
    //     .AddTransient<IValidator<ProcessedOrder>, ProcessedOrderValidator>()
    //     .AddTransient<IValidator<RejectedOrder>, RejectedOrderValidator>()
    //     .AddTransient<IValidator<OrderStatusUpdate>, OrderStatusUpdateValidator>()
    //     .AddTransient<IHttpRequestValidationWrapper<LabOrderDetailsRequest>, HttpRequestValidationWrapper<LabOrderDetailsRequest>>()
    //     .AddTransient<IHttpRequestValidationWrapper<KitOrderRequest>, HttpRequestValidationWrapper<KitOrderRequest>>()
    //     .AddTransient<IHttpRequestValidationWrapper<OrderStatusUpdate>, HttpRequestValidationWrapper<OrderStatusUpdate>>();

      // GBF validators
    //   builder.Services
    //     .AddTransient<IValidator<GbfModels.OrderRequest>, GbfValidators.OrderRequestValidator>()
    //     .AddTransient<IValidator<GbfModels.Order>, GbfValidators.OrderValidator>()
    //     .AddTransient<IValidator<GbfModels.OrderDetails>, GbfValidators.OrderDetailsValidator>();

    //   // Lab Order Validators
    //   builder.Services
    //     .AddTransient<IValidator<LabOrderDetailsRequest>, LabOrderDetailsRequestValidator>()
    //     .AddTransient<IValidator<LabOrderInfo>, LabOrderInfoValidator>()
    //     .AddTransient<IValidator<EmployerInfo>, EmployerInfoValidator>()
    //     .AddTransient<IValidator<MedicalDirector>, MedicalDirectorValidator>()
    //     .AddTransient<IValidator<PersonName>, PersonNameValidator>()
    //     .AddTransient<IValidator<PatientAddress>, PatientAddressValidator>()
    //     .AddTransient<IValidator<PatientDemographics>, PatientDemographicsValidator>()
    //     .AddTransient<IValidator<PhoneNumber>, PhoneNumberValidator>()
    //     .AddTransient<IValidator<LabLocationInfo>, LabLocationInfoValidator>()
    //     .AddTransient<IValidator<ServiceDetail>, ServiceDetailValidator>()
    //     .AddTransient<IValidator<ServiceDetailService>, ServiceDetailServiceValidator>();
    }
    }
}