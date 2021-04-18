param(
    [parameter(Mandatory=$true)]
    [ValidateSet("development", "stage", "production")]
    $Environment
)

$config = switch($Environment) {
    "development" {
        @{
            subscriptionName = "Windows Azure MSDN - Visual Studio Ultimate"
            terraformVarFile = "dev.tfvars"
            backendFile = "dev.backend.tfvars"
        }
        break;
    }
    "stage" {
        @{
            subscriptionName = "Windows Azure MSDN - Visual Studio Ultimate"
            terraformVarFile = "stage.tfvars"
            backendFile = "stage.backend.tfvars"
        }
        break;
    }
    "production" {
        @{
            subscriptionName = "Windows Azure MSDN - Visual Studio Ultimate"
            terraformVarFile = "prod.tfvars"
            backendFile = "prod.backend.tfvars"
        }
        break;
    }
}

$originalLocation = Get-Location
Set-Location "$PSScriptRoot"

az account set --subscription $config.subscriptionName

az account show -s $config.subscriptionName
# Deploy the infrastructure
terraform init -backend-config="$($config.backendFile)"

terraform destroy -force -var-file="$($config.terraformVarFile)"  
    
Set-Location $originalLocation
