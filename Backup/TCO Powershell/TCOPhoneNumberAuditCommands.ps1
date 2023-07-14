Connect-MicrosoftTeams

#Commands commented out to ensure people read and choose a command to run
#Reach out to Andrew Baird if you have questions
#12/04/2022 

#List all users and resource accounts with phone numbers assigned
#Get-CsOnlineUser | Where-Object  { $_.LineURI -notlike $null } | select DisplayName,UserPrincipalName,LineURI | export-csv C:\temp\Customer\assignednumbers.csv

#List all phone numbers in Teams admin portal and type subscriber = user and service/app numbers
#Get-CsOnlineTelephoneNumber | select Id,InventoryType| export-csv C:\temp\Customer\Allnumbers.csv

Disconnect-MicrosoftTeams