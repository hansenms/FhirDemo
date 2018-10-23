param(
    [Parameter(Mandatory = $true )]
    [ValidateNotNullOrEmpty()]
    [string]$EnvironmentName
)

if (-not (Get-Module -Name "FhirServer"))
{
    throw "Please load module FhirServer"
}

$fhirServiceName = $environmentName + "srvr"
$fhirClientName = $environmentName + "client"
$fhirServerUrl = "https://" + $fhirServiceName + ".azurewebsites.net"
$fhirClientUrl = "https://" + $fhirClientName + ".azurewebsites.net"
$fhirClientReplyUrl = $fhirClientUrl + "/.auth/login/aad/callback"

$apiAppReg = New-FhirServerApiApplicationRegistration -FhirServiceName $fhirServiceName
$clientAppReg = New-FhirServerClientApplicationRegistration -ApiAppId $apiAppReg.AppId -DisplayName $fhirClientName -IdentifierUri $fhirClientUrl -ReplyUrl $fhirClientReplyUrl

@{
    environmentName     = $EnvironmentName;
    aadAuthority = $apiAppReg.Authority;
    aadClientId  = $clientAppReg.AppId;
    aadClientSecret = $clientAppReg.AppSecret;
    aadAudience  = $apiAppReg.Audience;
}
