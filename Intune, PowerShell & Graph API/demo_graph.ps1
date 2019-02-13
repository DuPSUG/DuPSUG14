#region Load Helper function
. .\Connect_GraphAPI.ps1

get-help Connect-GraphAPI
#endregion

#region Authenticate
$credentials = (get-credential)
$credentials.Password.MakeReadOnly()

connect-azuread -Credential $credentials

Get-AzureADTenantDetail
$tenantID = (Get-AzureADTenantDetail).ObjectID

Get-AzureADApplication
$appID = (Get-AzureADApplication | where {$_.displayname -like '*Intune Automation*'}).AppID

$GraphCredentials = @{
    "AzureCredentials" = $credentials
    "TenantID" = $tenantID
    "AppID" = $appID
}

Connect-GraphAPI @GraphCredentials
#endregion

#region check header
$authHeader = Connect-GraphAPI @GraphCredentials
$authHeader
$authHeader.ExpiresOn.LocalDateTime
#endregion

#region set some variables
$graphApiVersion = "Beta"
$graphURI = "https://graph.microsoft.com/$graphapiversion"
$graphURI
#endregion

#region get user info
$Resource = "/users"
$uri = $graphURI + $Resource
$uri

Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader


$users = (Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader).value
$users
$users | select-object DisplayName, id
$userid = ($users | where {$_.displayname -like 'Ralph Eckhard'}).id
$userid

$uri
$uri = $uri + '/' + $userid
$uri

Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader
$UserRalph = (Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader)
$UserRalph.Displayname
$UserRalph | Select-Object DisplayName, MobilePhone, City

$PatchJSON = @{
  "mobilephone" = "+31640409642"
  "city" = "Heemskerk"
} | ConvertTo-Json

$PatchJSON

Invoke-RestMethod -Uri $uri -Method PATCH -Headers $authHeader -Body $PatchJSON -ContentType 'Application/JSON'

$UserRalph = (Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader)
$UserRalph | Select-Object DisplayName, MobilePhone, City
#endregion

#region create new user using Graph API
$Resource = "/users"
$uri = $graphURI + $Resource
$uri

$NewUserJSON = @{
    "accountEnabled"= $true
    "displayName"= "Dupsug Demo User"
    "mailNickname"= "dupsugdemouser"
    "userPrincipalName"= "dupsugdemouser@peoplewareppc.onmicrosoft.com"
    "passwordProfile" = @{
      "forceChangePasswordNextSignIn"= $true 
      "password"= "Welkom2019"
    }
  } | convertto-Json

$NewUserJSON

$response = Invoke-RestMethod -Uri $uri -Method POST -Headers $authHeader -Body $NewUserJSON -ContentType 'application/json'
$response
$response.displayname
$response.passwordprofile
$response.passwordProfile.forceChangePasswordNextSignIn
$response.id

$uri = $uri + '/' + $response.id
$uri
Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
#endregion

#region Delete created user
$Resource = "/users"
$uri = $graphURI + $Resource
$uri = $uri + '/dupsugdemouser@peoplewareppc.onmicrosoft.com'
$uri

Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader

Invoke-RestMethod -uri $uri -Method DELETE -Headers $authHeader

Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeader


#endregion

#region Groups
$Resource = "/groups"
$uri = $graphURI + $Resource
$uri

Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
$groups = (Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET).value
$groups | select DisplayName
#endregion

#region OneDrive
$Resource = "/drives"
$uri = $graphuri + $Resource
$uri

Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
$drives = (Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET).value
$drives
$drives[0].webUrl

Start-Process $drives[0].weburl
#endregion OneDrive

#region PoSH Scripts
$DPoSHURL = "https://graph.microsoft.com/beta/deviceManagement/devicemanagementscripts"
$DPoSHResults = (Invoke-RestMethod -Headers $authHeader -Method Get -Uri $DPoSHURL).value
foreach ($DPoSHResult in $DPoSHResults) {
$dposhname = $dposhresult.displayName
$dposhfile = "C:\temp\DupSUG\$dposhname" + '.json'
$dposhid = $DposhResult.id    
$DPoSHresultURL = "https://graph.microsoft.com/beta/deviceManagement/devicemanagementscripts/$dposhid"
$dposhdetail = Invoke-RestMethod -Headers $authHeader -URI $dposhresulturl -method Get
$dposhdetail | ConvertTo-Json | out-file $dposhfile
}

$scriptcontent = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($dposhdetail.scriptcontent))
$scriptcontent | out-file C:\temp\DuPSUG\script.ps1
#endregion PoSH Scripts
