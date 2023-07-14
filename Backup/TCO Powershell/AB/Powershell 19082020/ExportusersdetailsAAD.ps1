

Connect-AzureAD
Get-AzureADUser -all $true | select DisplayName,UserPrincipalName,Department,City,CompanyName,JobTitle,Mobile,TelephoneNumber | Export-CSV -path C:\temp\NCPHNusers.csv