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

$username = (Get-AzureADCurrentSessionInfo).Account.Id
$username_rep = $username.Replace('@','_') #External accounts have a different form of UPN
$aadUser = Get-AzureADUser -Filter "startswith(userPrincipalName, '$username') or startswith(userPrincipalName, '$username_rep')"

$fhirServiceName = $environmentName + "srvr"
$fhirClientName = $environmentName + "client"
$fhirServerUrl = "https://" + $fhirServiceName + ".azurewebsites.net"
$fhirClientUrl = "https://" + $fhirClientName + ".azurewebsites.net"
$fhirClientReplyUrl = $fhirClientUrl + "/.auth/login/aad/callback"

$apiAppReg = New-FhirServerApiApplicationRegistration -FhirServiceName $fhirServiceName -AppRoles admin
$clientAppReg = New-FhirServerClientApplicationRegistration -ApiAppId $apiAppReg.AppId -DisplayName $fhirClientName -IdentifierUri $fhirClientUrl -ReplyUrl $fhirClientReplyUrl

# Make the app registration an admin, since we will be using it for data movement
# This could be a separate service principal
Set-FhirServerClientAppRoleAssignments -AppId $clientAppReg.AppId -ApiAppId $apiAppReg.AppId -AppRoles admin

# Make the current user an admin
Set-FhirServerUserAppRoleAssignments -UserPrincipalName $aadUser.UserPrincipalName -ApiAppId $apiAppReg.AppId -AppRoles admin

@{
    environmentName     = $EnvironmentName;
    aadAuthority = $apiAppReg.Authority;
    aadClientId  = $clientAppReg.AppId;
    aadClientSecret = $clientAppReg.AppSecret;
    aadAudience  = $apiAppReg.Audience;
}
