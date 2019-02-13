function Connect-GraphAPI
{
  <#
    .SYNOPSIS
    Sets up a connection to the Graph API in PowerShell
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    Connect-GraphAPI
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $tenantID,

    [Parameter(Mandatory=$true)]
    [String]
    $appID,

    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential]
    $AzureCredentials

  )

  #Setting Paramaters
  $tenant = $tenantID
  $intuneAutomationAppId = $appID
  $AadModule = Import-Module -Name AzureAD -ErrorAction Stop -PassThru
  
  #Authenticate with the Graph API REST interface
  $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
  $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
  [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
  [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null
  $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
  $resourceAppIdURI = "https://graph.microsoft.com"
  $authority = "https://login.microsoftonline.com/$tenant"
  
  try {
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority 
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($AzureCredentials.Username, "OptionalDisplayableId")   
    $userCredentials = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.UserPasswordCredential -ArgumentList $AzureCredentials.Username, $AzureCredentials.Password
    $authResult = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContextIntegratedAuthExtensions]::AcquireTokenAsync($authContext, $resourceAppIdURI, $intuneAutomationAppId, $userCredentials);
    
    if ($authResult.Result.AccessToken) {
      $authHeader = @{
        'Content-Type'  = 'application/json'
        'Authorization' = "Bearer " + $authResult.Result.AccessToken
        'ExpiresOn'     = $authResult.Result.ExpiresOn
      }
      return $authHeader
    }
    elseif ($authResult.Exception) {
      throw "An error occured getting access token: $($authResult.Exception.InnerException)"
    }
  }
  catch { 
    throw $_.Exception.Message 
  }	
connect-AzureAD -Credential $AzureCredentials
}

