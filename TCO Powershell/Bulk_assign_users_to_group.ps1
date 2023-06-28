#$Credentials = Get-Credential
#Connect-MsolService -Credential $credentials


#Coonect as an admin to Microsoft Office 365 Tenant
Connect-MSOLService
Connect-AzureAD
Import-Module AzureAD

#Filename is the csv with user list heading UPN
$Filename = "c:\temp\group_users.csv"


#Import users
$users="null"
write-host $users -foregroundcolor Green 
$users= import-csv $FileName -Encoding UTF8
write-host $users -foregroundcolor Green 

$groupName="SG-MFA-SSPR-Registration-Users"

foreach($user in $users)
{
$upn = $user.UPN
$DisplayName = $user.DisplayName
write-host "Input UPN:" $upn -foregroundcolor Green
write-host "Input DisplayName:" $DisplayName -foregroundcolor Green
write-host "UPN:" (Get-AzureADUser -all $true | Where { $_.UserPrincipalName -eq $upn }).ObjectID -foregroundcolor Green 
write-host "Display:" (Get-AzureADUser -all $true | Where { $_.DisplayName -eq $DisplayName }).ObjectID -foregroundcolor Green 
#Get-AzureADUser -filter "userprincipalname eq '$upn'" | % {add-AzureADGroupMember -identity SG-MFA-SSPR-Registration-Users -members $_} -Verbose
#Add-AzureADGroupMember -RefObjectId (Get-AzureADUser | Where { $_.UserPrincipalName -eq $userUPN }).ObjectID -ObjectId (Get-AzureADGroup | Where { $_.DisplayName -eq $groupName }).ObjectID
#Get-AzureADUser -filter "userprincipalname eq '$upn'" | % {Add-AzureADGroupMember -RefObjectID (Get-AzureADUser | Where { $_.UserPrincipalName -eq $upn}).ObjectID  -ObjectId (Get-AzureADGroup | Where { $_.DisplayName -eq $groupName }).ObjectID} -Verbose
#Add-AzureADGroupMember -RefObjectID (Get-AzureADUser | Where { $_.UserPrincipalName -eq $upn }).ObjectID -ObjectId (Get-AzureADGroup | Where { $_.DisplayName -eq $groupName }).ObjectID
Add-AzureADGroupMember -RefObjectID (Get-AzureADUser -all $true | Where { $_.DisplayName -eq $DisplayName }).ObjectID -ObjectId (Get-AzureADGroup | Where { $_.DisplayName -eq $groupName }).ObjectID
}

