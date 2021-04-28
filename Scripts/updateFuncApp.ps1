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
    [ValidateSet("Development", "Stage", "Production")]
    $Environment
)

Import-Module "$PSScriptRoot/Modules/deploymentHelpers.psm1"

$config = switch ($Environment) {
    "Development" {
        @{
            EphShippingUpdateUrl     = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOAuth2Url             = "https://api-load-we.test.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "true";
          }
        break;
    }
    "Stage" {
        @{
            EphShippingUpdateUrl     = "https://api-load-we.test.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOAuth2Url             = "https://api-load-we.test.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "true";
        }
        break;
    }
    "Production" {
        @{
            EphShippingUpdateUrl     = "https://api.questforhealth.com/1.0/api/AdvancedKit/KitSent";
            EphOAuth2Url             = "https://api.questforhealth.com/1.0/api/Token/OAuth2"
            GbfAllTestOrders         = "false";
        }
        break;
    }

}

$cosmosStrings = Get-AzCosmosDBAccountKey -ResourceGroupName $ResourceGroupName -Name $CosmosDb -Type "ConnectionStrings"
$cosmosPrimaryString = $cosmosStrings.'Primary SQL Connection String'

# Get Secrets from the Vault
# # # # $quanumUser = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "QuanumUser").SecretValue | ConvertFrom-SecureString -AsPlainText
# # # # $quanumPassword = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "QuanumPassword").SecretValue | ConvertFrom-SecureString -AsPlainText
# # # # $ephClientSecret = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "EphClientSecret").SecretValue | ConvertFrom-SecureString -AsPlainText
# # # # $gbfBearerToken = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "GbfBearerToken").SecretValue | ConvertFrom-SecureString -AsPlainText
# # # # $pwnApiToken = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "PwnApiToken").SecretValue | ConvertFrom-SecureString -AsPlainText
# # # # $pwnApiKey = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "PwnApiKey").SecretValue | ConvertFrom-SecureString -AsPlainText

# NOTE: The GbfOrderStatusEndpoint setting requires knowledge of the API Endpoints that are
# created in the `importApis.ps1` script, so if the "gbf" prefix for the URLs changes, the update needs
# to be reflected in both places
$envAbbr = Get-EnvAbbreviation -Environment $Environment

$hash = @{
    "FUNCTIONS_EXTENSION_VERSION"            = "~3";
    "Cosmos:ConnectionString"                = $cosmosPrimaryString;
    "Cosmos:DatabaseName"                    = "slots";
    "Eph:OAuth2Url"                          = $config.EphOAuth2Url;
    "Eph:ShippingUpdateUrl"                  = $config.EphShippingUpdateUrl;
    "Gbf:AllTestOrders"                      = $config.GbfAllTestOrders;
}

Update-AzFunctionAppSetting -Name $FunctionAppName -ResourceGroupName $ResourceGroupName -AppSetting $hash -Force