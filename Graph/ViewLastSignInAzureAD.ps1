$AppId = "xxxxxxxxxxxxxxxxxxxxx" #clientID of your AAD app, must have User.Read.All, Directory.Read.All, Auditlogs.Read.All permissions
$client_secret = Get-Content .\ReportingAPIsecret.txt | ConvertTo-SecureString -AsPlainText -Force #save secret in directory where Powershell is running and name the text file ReportAPISecret.txt
$app_cred = New-Object System.Management.Automation.PsCredential($AppId, $client_secret)
$TenantId = "xxxxxxxxxxxxxxxxxxxxxx" #your tenant

$body = @{
    client_id     = $AppId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $app_cred.GetNetworkCredential().Password
    grant_type    = "client_credentials"
}
 
#simple code to get an access token, add your own handlers as needed
try { $tokenRequest = Invoke-WebRequest -Method Post -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing -ErrorAction Stop }
catch { Write-Host "Unable to obtain access token, aborting..."; return }

$token = ($tokenRequest.Content | ConvertFrom-Json).access_token

#Form request headers with the acquired $AccessToken
$headers = @{'Content-Type'="application\json";'Authorization'="Bearer $token"}
 
#This request get users list with signInActivity.
$ApiUrl = "https://graph.microsoft.com/beta/users?`$select=displayName,userPrincipalName,signInActivity,userType,assignedLicenses&`$top=999"
 
$Result = @()
While ($ApiUrl -ne $Null) #Perform pagination if next page link (odata.nextlink) returned.
{
$Response = Invoke-WebRequest -Method GET -Uri $ApiUrl -ContentType "application\json" -Headers $headers | ConvertFrom-Json
if($Response.value)
{
$Users = $Response.value
ForEach($User in $Users)
{
 
$Result += New-Object PSObject -property $([ordered]@{ 
DisplayName = $User.displayName
UserPrincipalName = $User.userPrincipalName
LastSignInDateTime = if($User.signInActivity.lastSignInDateTime) { [DateTime]$User.signInActivity.lastSignInDateTime } Else {$null}
IsLicensed  = if ($User.assignedLicenses.Count -ne 0) { $true } else { $false }
IsGuestUser  = if ($User.userType -eq 'Guest') { $true } else { $false }
})
}
 
}
$ApiUrl=$Response.'@odata.nextlink'
}
$Result | Export-CSV "C:\LastLoginDateReport.CSV" -NoTypeInformation -Encoding UTF8
