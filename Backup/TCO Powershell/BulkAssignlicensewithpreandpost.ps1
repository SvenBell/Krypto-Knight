$Credentials = Get-Credential
Connect-MsolService -Credential $credentials

#Add the SKU id you want to add license for
$SKU = "banjosrccomau:ENTERPRISEPREMIUM"
#Filename is the csv with user list heading UPN
#Note for AndrewB: Get-MSOLUser | % { $upn=$_; $_.Licenses | Select {$upn.displayname},AccountSKuid } | Export-CSV "C:\temp\banjospre-licenses.csv" -NoTypeInformation
$Filename = "C:\Temp\Banjosuserlist.csv"


    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        Get-Msoluser -UserPrincipalName $upn | select UserPrincipalName,UsageLocation,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},DisplayName | export-csv "C:\temp\banjospre-licenses.csv" -Append -NoTypeInformation
        Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU"
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $SKU -Verbose -RemoveLicenses "banjosrccomau:O365_BUSINESS_PREMIUM"
        Get-Msoluser -UserPrincipalName $upn | select UserPrincipalName,UsageLocation,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},DisplayName | export-csv "C:\temp\banjospost-licenses.csv" -Append -NoTypeInformation
    } 

