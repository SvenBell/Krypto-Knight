#Install-module AzureAD
#import-module AzureAD
Connect-AzureAD

$group = Get-AzureADGroup -SearchString "SG-Callqueue"

Get-AzureADGroupMember -ObjectId $group.ObjectId | select DisplayName, UserPrincipalName, AccountEnabled | export-csv C:\temp\SG-CallQueueMobility.csv
