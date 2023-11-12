#Connect to Azure
$Credential = Get-Credential
Connect-AzureAD -Credential $Credential

#Check for AAD premium license
$licenses = Get-AzureADSubscribedSku | select SkuPartNumber
$licenses = $licenses -match 'AAD_PREMIUM' -or 'SPB'
If($licenses -eq $null -or $licenses -eq ""){
    Write-Host "Client does not have AAD Premium licensing"
    Read-Host “Press ENTER to exit...”
    Exit}
Else{
    Write-Host "Confirmed " (Get-AzureADTenantDetail).DisplayName " has AAD Premium"
}

#Check for existing groups, if either of these already exist the script will exit
$mfaExcluded = Get-AzureADGroup -All $true | where-object DisplayName -eq "MFA - Excluded"
$mfaGlobalRoaming = Get-AzureADGroup -All $true | where-object DisplayName -eq "MFA - Global Roaming"

If($mfaExcluded -eq $null -or $mfaExcluded -eq ""){

#Create MFA - Excluded group
New-AzureADGroup -DisplayName "MFA - Excluded" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet" -Description "Members are excluded from MFA, provided they connect from on premises"
Write-Host "MFA - Excluded Roaming Group created!"
}
else {
    Write-Host "MFA - Excluded group already exists! Confirm client doesn't already have MFA setup."
    Read-Host “Press ENTER to exit...”
    Exit
    }

#Get MFA - Excluded Object ID for repeated use
$mfaExcludedGroup = (Get-AzureADGroup -SearchString "MFA - Excluded").ObjectId

#Add connected user to MFA - Excluded group
Add-AzureADGroupMember -ObjectId $mfaExcludedGroup -RefObjectId (Get-AzureADUser -ObjectId $Credential.UserName).ObjectId
Write-Host $Credential.UserName + " has been added to the MFA - Excluded group"

If($mfaGlobalRoaming -eq $null -or $mfaGlobalRoaming -eq ""){

#Create MFA - Global Roaming group
New-AzureADGroup -DisplayName "MFA - Global Roaming" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet" -Description "Members are permitted to authenticate from Intl. Locations. As defined in 'Named Locations'"
Write-Host "MFA - Global Roaming Group created!"
}
else {
    Write-Host "MFA - Global Roaming group already exists! Confirm client doesn't already have MFA setup."
    Read-Host “Press ENTER to exit...”
    Exit
    }

#Get MFA - Global Roaming Object ID for repeated use
$mfaGlobalRoamingGroup = (Get-AzureADGroup -SearchString "MFA - Global Roaming").ObjectId

#Add connected user to MFA - Global Roaming group
Add-AzureADGroupMember -ObjectId $mfaGlobalRoamingGroup -RefObjectId (Get-AzureADUser -ObjectId $Credential.UserName).ObjectId
Write-Host $Credential.UserName + " has been added to the MFA - Global Roaming group"

#define functions to create the required policies
Function createNotAustralia{
#Create named locations
#Not Australia
$countries = @("ZW","ZM","YE","WF","VI","VG","VN","VE","VU","UZ","UM","UY","US","GB","AE","UA","UG","TV","TC","TM","TR","TN","TT","TO","TK","TG","TL","TH","TZ","TJ","TW","SY","CH","SE","SZ","SJ","SR","SD","LK","ES","SS","GS","ZA","SO","SB","SI","SK","SX","SG","SL","SC","RS","SN","SA","ST","SM","WS","VC","PM","MF","LC","KN","SH","BL","RW","RU","RO","RE","CG","QA","PR","PT","PL","PN","PH","PE","PY","PG","PA","PS","PW","PK","OM","NO","MP","MK","KP","NF","NU","NG","NE","NI","NZ","NC","NL","NP","NR","NA","MM","MZ","MA","MS","ME","MN","MC","MD","FM","MX","YT","MU","MR","MQ","MH","MT","ML","MV","MY","MW","MG","MO","LU","LT","LI","LY","LR","LS","LB","LV","LA","KG","KW","KR","KI","KE","KZ","JO","JE","JP","JM","IT","IL","IM","IE","IQ","IR","ID","IN","IS","HU","HK","HN","VA","HM","HT","GY","GW","GN","GG","GT","GU","GP","GD","GL","GR","GI","GH","DE","GE","GM","GA","TF","PF","GF","FR","FI","FJ","FO","FK","ET","EE","ER","GQ","SV","EH","EG","EC","DO","DM","DJ","DK","CD","CZ","CY","CW","CU","HR","CI","CR","CK","KM","CO","CC","CX","CN","CL","TD","CF","KY","CA","CM","KH","CV","BI","BF","BG","BN","IO","BR","BV","BW","BA","BQ","BO","BT","BM","BJ","BZ","BE","BY","BB","BD","BH","BS","AZ","AT","AW","AM","AR","AG","AQ","AI","AO","AD","AS","DZ","AL","AX","AF")
New-AzureADMSNamedLocationPolicy -OdataType "#microsoft.graph.countryNamedLocation" -DisplayName "International (Not Aust.)" -CountriesAndRegions $countries -IncludeUnknownCountriesAndRegions $false
}

Function createRMTlocation{
#RMT Offices
[System.Collections.Generic.List`1[Microsoft.Open.MSGraph.Model.IpRange]]$list = @()
$list.Add("203.54.136.130/32")
$list.Add("58.171.72.102/32")
$list.Add("203.44.73.122/32")
$list.Add("110.142.22.145/32")
New-AzureADMSNamedLocationPolicy -OdataType "#microsoft.graph.ipNamedLocation" -DisplayName "RMT Offices" -IsTrusted $true -IpRanges $list
}

Function createGeoBlock{
#Create General Geo Blocking policy
$international = Get-AzureADMSNamedLocationPolicy | where {$_.displayName -eq "International (Not Aust.)"}
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Applications.IncludeApplications = "All"
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$conditions.Users.IncludeUsers = "All"
$conditions.Users.ExcludeGroups = $mfaGlobalRoamingGroup
$conditions.Locations = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessLocationCondition
$conditions.Locations.IncludeLocations = $international.Id
$conditions.ClientAppTypes = "All"
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"
New-AzureADMSConditionalAccessPolicy -DisplayName "General GeoBlocking policy" -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls
}

Function createBasicAuthentication{
#Disable Basic Authentication
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Applications.IncludeApplications = "All"
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$conditions.Users.IncludeUsers = "All"
$conditions.Locations = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessLocationCondition
$conditions.Locations.IncludeLocations = "All"
$conditions.Locations.ExcludeLocations = "AllTrusted"
$conditions.ClientAppTypes = "Other"
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"
New-AzureADMSConditionalAccessPolicy -DisplayName "Disable Basic Authentication" -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls
}

Function restrictNonMfa{
#Restrict non MFA users to Trusted Locations
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Applications.IncludeApplications = "All"
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$conditions.Users.IncludeGroups = $mfaExcludedGroup
$conditions.Locations = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessLocationCondition
$conditions.Locations.IncludeLocations = "All"
$conditions.Locations.ExcludeLocations = "AllTrusted"
$conditions.ClientAppTypes = "All"
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$controls._Operator = "OR"
$controls.BuiltInControls = "Block"
New-AzureADMSConditionalAccessPolicy -DisplayName "Restrict non MFA users to Trusted Locations" -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls
}

Function mfaPolicy{
#Multi Factor Authentication Policy
$conditions = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessConditionSet
$conditions.Applications = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessApplicationCondition
$conditions.Applications.IncludeApplications = "All"
$conditions.Users = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessUserCondition
$conditions.Users.IncludeUsers = "All"
$conditions.Users.ExcludeGroups = $mfaExcludedGroup
$conditions.Locations = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessLocationCondition
$conditions.Locations.IncludeLocations = "All"
$conditions.Locations.ExcludeLocations = "AllTrusted"
$conditions.ClientAppTypes = "All"
$controls = New-Object -TypeName Microsoft.Open.MSGraph.Model.ConditionalAccessGrantControls
$controls._Operator = "OR"
$controls.BuiltInControls = "Mfa"
New-AzureADMSConditionalAccessPolicy -DisplayName "Multi Factor Authentication Policy" -State "enabledForReportingButNotEnforced" -Conditions $conditions -GrantControls $controls}


#Calling the functions to create policies, advises of success or error message if fails
try {createNotAustralia
      Write-Host "Not Australia location was successfully created for" (Get-AzureADTenantDetail).DisplayName
      }
catch {
    Write-Host "Not Australia location was not setup:"
    Write-Host $_
    }

try {createRMTlocation
      Write-Host "RMT Trusted location was successfully created for" (Get-AzureADTenantDetail).DisplayName
      }
catch {
    Write-Host "RMT Trusted location was not setup:"
    Write-Host $_
    }

try {createGeoBlock
    Write-Host "Geo Blocking policy was successfully created for" (Get-AzureADTenantDetail).DisplayName
      }
catch {
    Write-Host "Geo Blocking policy was not setup:"
    Write-Host $_
    }

try {createBasicAuthentication
      Write-Host "Basic Authentication policy was successfully created for" (Get-AzureADTenantDetail).DisplayName
      }
catch {
    Write-Host "Basic Authentication policy was not setup:"
    Write-Host $_
    }

try {restrictNonMfa
      Write-Host "Restrict Non MFA policy was successfully created for" (Get-AzureADTenantDetail).DisplayName
      }
catch {
    Write-Host "Restrict Non MFA policy was not setup:"
    Write-Host $_
    }

try {mfaPolicy
      Write-Host "Multi Authentication policy was successfully created for" (Get-AzureADTenantDetail).DisplayName
      }
catch {
    Write-Host "Basic Authentication policy was not setup:"
    Write-Host $_
    }
Write-Host “Setup Complete"
Read-Host "Press ENTER to exit...”