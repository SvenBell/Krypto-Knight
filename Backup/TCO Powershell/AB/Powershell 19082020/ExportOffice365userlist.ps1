$Credentials = Get-Credential
Connect-MsolService -Credential $credentials


Get-MsolUser -enabledFilter EnabledOnly | select FirstName,Lastname,DisplayName,UserPrincipalName,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},UsageLocation,Department,City,CompanyName,JobTitle | Export-CSV -path C:\temp\Cropsmart_exportusers_02032020.csv

#| select DisplayName,UserPrincipalName,Department,City,CompanyName,JobTitle,Mobile,TelephoneNumber