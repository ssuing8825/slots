
<#
  .Synopsis
  Converts a more verbose environment name into the abbreviation used in our infrastructure,
  namely the terraform files. (e.g. "Production" => "prd")

  .Parameter Environment
  The Environment string to convert

  .Inputs
  None.

  .Outputs
  System.String. The resulting abbreviation, or the input value if no mapping is found

  .Example
  # Convert "Production" (returns "prd")
  Get-EnvAbbreviation -Environment "Production"
#>
function Get-EnvAbbreviation {
    param(
      # Environment Parameter
      [Parameter(Mandatory = $true)]
      [string]$Environment
    )
  
    # since we only have to map things that are different, we don't have to list things like "qa", "stage", "prod", etc.
    $mappings = @{
      Sandbox = "sb";
      Development = "dev";
      Production = "prod";
    }
  
    $result = $mappings[$Environment]
    if ($result) {
      return $result
    }
    return $Environment.ToLower()
  }
  
  
  Export-ModuleMember -Function Get-EnvAbbreviation