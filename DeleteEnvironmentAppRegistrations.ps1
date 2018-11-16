param(
    [Parameter(Mandatory = $true )]
    [ValidateLength(1,12)]
    [string]$EnvironmentName
)

if (-not (Get-Module -Name "FhirServer"))
{
    throw "Please load module FhirServer"
}

# Get current AzureAd context
try {
    Get-AzureADCurrentSessionInfo -ErrorAction Stop | Out-Null
} 
catch {
    throw "Please log in to Azure AD with Connect-AzureAD cmdlet before proceeding"
}

$fhirServiceName = $EnvironmentName + "srvr"
$fhirClientName = $EnvironmentName + "client"
$fhirServiceClientName = $EnvironmentName + "service"

$fhirServerUrl = "https://" + $fhirServiceName + ".azurewebsites.net"

$apiAppReg = Get-AzureADApplication -Filter "IdentifierUris eq '$fhirServerUrl'"
$clientAppReg = Get-AzureADApplication -Filter "DisplayName eq '$fhirClientName'"
$serviceClientAppReg = Get-AzureADApplication -Filter "DisplayName eq'$fhirServiceClientName'"

Remove-FhirServerApplicationRegistration -AppId $clientAppReg.AppId
Remove-FhirServerApplicationRegistration -AppId $serviceClientAppReg.AppId
Remove-FhirServerApplicationRegistration -AppId $apiAppReg.AppId
