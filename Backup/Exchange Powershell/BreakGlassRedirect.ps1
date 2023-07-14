# Import-Module ExchangeOnlineManagement
# Connect-ExchangeOnline -UserPrincipalName stephen.bell@YYYYY.com.au

$adminMail = "breakglass@spearpointtechnology.onmicrosoft.com" 
$userMail = "stephen.bell@spearpoint.net.au,andrew.jiear@spearpoint.net.au,james.clifford@spearpoint.net.au" 

$name = ($adminMail -replace "@","_").Replace(".","-") 

New-DistributionGroup -Name "DG-Admin Alert Redirect" -Alias "$name`_admin" -PrimarySMTPAddress "$($adminMail)" -ManagedBy "$userMail" -CopyOwnerToMember -MemberDepartRestriction "Closed" -MemberJoinRestriction "Closed" 

Set-DistributionGroup "DG-Admin Alert Redirect" -HiddenFromAddressListsEnabled $true -RequireSenderAuthenticationEnabled $true -Description "Distribution list that redirects the break glass accounts admin alerts to the members mailboxes"

#Add-DistributionGroupMember -Identity "DG-Admin Alert Redirect" -Member "andrew.jiear@spearpoint.net.au,james.clifford@spearpoint.net.au"

#Update-DistributionGroupMember -Identity "Research Reports" -Members chris@contoso.com,michelle@contoso.com,laura@contoso.com,julia@contoso.com