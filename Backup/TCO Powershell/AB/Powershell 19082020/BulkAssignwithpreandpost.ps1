$Credentials = Get-Credential
Connect-MsolService -Credential $credentials
get-MsolAccountSku
#Add the SKU id you want to add license for
$SKU = "handsontherapycomau:STANDARDPACK"
#Filename is the csv with user list heading UPN
#Note for AndrewB: Get-MSOLUser | % { $upn=$_; $_.Licenses | Select {$upn.displayname},AccountSKuid } | Export-CSV "C:\temp\banjospre-licenses.csv" -NoTypeInformation
$Filename = "C:\Temp\Handsonuserlist.csv"


    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        #Get-Msoluser -UserPrincipalName $upn | select UserPrincipalName,UsageLocation,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},DisplayName | export-csv "C:\temp\handsonpre-licenses.csv" -Append -NoTypeInformation
        #Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU"
        #Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $SKU -Verbose -RemoveLicenses "handsontherapycomau:O365_BUSINESS_ESSENTIALS"
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses "handsontherapycomau:MCOEV" -Verbose
        Write-Host $upn -foregroundcolor Green
        #Get-Msoluser -UserPrincipalName $upn | select UserPrincipalName,UsageLocation,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},DisplayName | export-csv "C:\temp\handsonpost-licenses.csv" -Append -NoTypeInformation
    } 

