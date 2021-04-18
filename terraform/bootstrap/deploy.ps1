param(
    [parameter(Mandatory=$true)]
    [ValidateSet("development","stage","production")]
    $Environment
)

$config = switch($Environment) {
    "development" {
        @{
            subscriptionName = "Windows Azure MSDN - Visual Studio Ultimate"
            terraformVarFile = "dev.tfvars"
        }
        break;
    }
    "stage" {
        @{
            subscriptionName = "Windows Azure MSDN - Visual Studio Ultimate"
            terraformVarFile = "stage.tfvars"
        }
        break;
    }
    "production" {
        @{
            subscriptionName = "Windows Azure MSDN - Visual Studio Ultimate"
            terraformVarFile = "prod.tfvars"
        }
        break;
    }
}

$originalLocation = Get-Location
Set-Location "$PSScriptRoot"
az account set --subscription $config.subscriptionName

# Deploy the infrastructure
terraform init
terraform apply -var-file="$($config.terraformVarFile)" -state="$($environment)_terraform.tfstate" -auto-approve

Set-Location $originalLocation