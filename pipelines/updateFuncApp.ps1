<#

.SYNOPSIS
Updates App Settings in the Azure Function App by grabbing secrets from the Key Vault. 
This will eventually be replaced by Managed Identities.

#>

param(
    [parameter(Mandatory = $true)]
    [String]
    $FunctionAppName,

    [parameter(Mandatory = $true)]
    [String]
    $VaultName,

    [parameter(Mandatory = $true)]
    [String]
    $ResourceGroupName,

    [parameter(Mandatory = $true)]
    [String]
    $CosmosDb,
    # Environment Parameter
    [Parameter(Mandatory = $true)]
    [ValidateSet("Sandbox", "Development", "QA", "Stage", "Production")]
    $Environment
)

Import-Module "$PSScriptRoot/Modules/deploymentHelpers.psm1"

$config = switch ($Environment) {
    "Sandbox" {
        @{
            EphShippingUpdateUrl     = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOrderUpdatesUrl       = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitUpdate";
            EphBaseUrl               = "https://api-load-we.test.questforhealth.com/1.0/";
            EphClientId              = "APIServiceAccountUser";
            EphScope                 = "default";
            EphOAuth2Url             = "https://api-load-we.test.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "true";
            IsSendToKitVendorEnabled = "false";
            PwnRootUrl               = "https://api-staging.pwnhealth.com/";
            QuanumBaseUrl            = "https://certhubservices.quanum.com/";
        }
        break;
    }
    "Development" {
        @{
            EphShippingUpdateUrl     = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOrderUpdatesUrl       = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitUpdate";
            EphBaseUrl               = "https://api-load-we.test.questforhealth.com/1.0/";
            EphClientId              = "APIServiceAccountUser";
            EphScope                 = "default";
            EphOAuth2Url             = "https://api-load-we.test.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "true";
            IsSendToKitVendorEnabled = "false";
            PwnRootUrl               = "https://api-staging.pwnhealth.com/";
            QuanumBaseUrl            = "https://certhubservices.quanum.com/";
        }
        break;
    }
    "QA" {
        @{
            EphShippingUpdateUrl     = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOrderUpdatesUrl       = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitUpdate";
            EphBaseUrl               = "https://api-load-we.test.questforhealth.com/1.0/";
            EphClientId              = "APIServiceAccountUser";
            EphScope                 = "default";
            EphOAuth2Url             = "https://api-load-we.test.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "true";
            IsSendToKitVendorEnabled = "false";
            PwnRootUrl               = "https://api-staging.pwnhealth.com/";
            QuanumBaseUrl            = "https://certhubservices.quanum.com/";
        }
        break;
    }
    "Stage" {
        @{
            EphShippingUpdateUrl     = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOrderUpdatesUrl       = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitUpdate";
            EphBaseUrl               = "https://api-load-we.test.questforhealth.com/1.0/";
            EphClientId              = "APIServiceAccountUser";
            EphScope                 = "default";
            EphOAuth2Url             = "https://api-load-we.test.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "true";
            IsSendToKitVendorEnabled = "false";
            PwnRootUrl               = "https://api-staging.pwnhealth.com/";
            QuanumBaseUrl            = "https://certhubservices.quanum.com/";
        }
        break;
    }
    "Production" {
        @{
            EphShippingUpdateUrl     = "https://api.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOrderUpdatesUrl       = "https://api.questforhealth.com/1.0/api/AdvancedKit/KitUpdate";
            EphBaseUrl               = "https://api.questforhealth.com/1.0/";
            EphClientId              = "aisserviceintegration";
            EphScope                 = "default";
            EphOAuth2Url             = "https://api.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "false";
            IsSendToKitVendorEnabled = "true";
            PwnRootUrl               = "https://api.pwnhealth.com/";
            QuanumBaseUrl            = "https://hubservices.quanum.com/";
        }
        break;
    }

}

$cosmosStrings = Get-AzCosmosDBAccountKey -ResourceGroupName $ResourceGroupName -Name $CosmosDb -Type "ConnectionStrings"
$cosmosPrimaryString = $cosmosStrings.'Primary SQL Connection String'

# Get Secrets from the Vault
$quanumUser = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "QuanumUser").SecretValue | ConvertFrom-SecureString -AsPlainText
$quanumPassword = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "QuanumPassword").SecretValue | ConvertFrom-SecureString -AsPlainText
$ephClientSecret = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "EphClientSecret").SecretValue | ConvertFrom-SecureString -AsPlainText
$gbfBearerToken = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "GbfBearerToken").SecretValue | ConvertFrom-SecureString -AsPlainText
$pwnApiToken = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "PwnApiToken").SecretValue | ConvertFrom-SecureString -AsPlainText
$pwnApiKey = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "PwnApiKey").SecretValue | ConvertFrom-SecureString -AsPlainText

# NOTE: The GbfOrderStatusEndpoint setting requires knowledge of the API Endpoints that are
# created in the `importApis.ps1` script, so if the "gbf" prefix for the URLs changes, the update needs
# to be reflected in both places
$envAbbr = Get-EnvAbbreviation -Environment $Environment

$hash = @{
    "FUNCTIONS_EXTENSION_VERSION"            = "~3";
    "Cosmos:ConnectionString"                = $cosmosPrimaryString;
    "Cosmos:DatabaseName"                    = "ghkoat";
    "Eph:BaseUrl"                            = $config.EphBaseUrl;
    "Eph:ClientId"                           = $config.EphClientId;
    "Eph:ClientSecret"                       = $ephClientSecret;
    "Eph:OAuth2Url"                          = $config.EphOAuth2Url;
    "Eph:OrderUpdatesUrl"                    = $config.EphOrderUpdatesUrl;
    "Eph:Scope"                              = $config.EphScope;
    "Eph:ShippingUpdateUrl"                  = $config.EphShippingUpdateUrl;
    "Flags:IsSendOrderToKitVendorEnabled"    = $config.IsSendToKitVendorEnabled;
    "Flags:IsSendOrderToPwnEnabled"          = "true";
    "Flags:IsSendOrderToQuanumEnabled"       = "true";
    "Flags:IsSendShippingToBuEnabled"        = "true";
    "Gbf:AllTestOrders"                      = $config.GbfAllTestOrders;
    "Gbf:BaseUrl"                            = "https://www.gbfmedical.com/";
    "Gbf:BearerToken"                        = $gbfBearerToken;
    "Gbf:KitOrderUrl"                        = "oap/api/order";
    "Gbf:ApiRetryBackoffCoefficient"         = 5;
    "Gbf:ApiRetryFirstIntervalMillis"        = 30000;
    "Gbf:ApiRetryMaxAttempts"                = 5;
    "Gbf:OrderStatusEndpoint"                = "https://apim-ghkoat-eus-$envAbbr.azure-api.net/gbf/api/gbf/shipping-info";
    "Pwn:ApiKey"                             = $pwnApiKey;
    "Pwn:ApiToken"                           = $pwnApiToken;
    "Pwn:CreateOrderUrl"                     = "v2/labs/orders";
    "Pwn:RootUrl"                            = $config.PwnRootUrl;
    "Quanum:BaseUrl"                         = $config.QuanumBaseUrl;
    "Quanum:OrderEndpoint"                   = "rest/orders/v1/submission";
    "Quanum:Password"                        = $quanumPassword;
    "Quanum:Username"                        = $quanumUser;
    "RetryLogic:ApiRetryBackoffCoefficient"  = 1;
    "RetryLogic:ApiRetryFirstIntervalMillis" = 30000;
    "RetryLogic:ApiRetryMaxAttempts"         = 3;
}

Update-AzFunctionAppSetting -Name $FunctionAppName -ResourceGroupName $ResourceGroupName -AppSetting $hash -Force