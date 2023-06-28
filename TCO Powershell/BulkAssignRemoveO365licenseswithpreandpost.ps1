#Find the SKU id for TCO
get-MsolAccountSku
#Example
#AccountSkuId                          ActiveUnits WarningUnits ConsumedUnits
#------------                          ----------- ------------ -------------
#banjosrccomau:VISIOCLIENT             1           0            1            
#banjosrccomau:ENTERPRISEPREMIUM       25          0            25           
#banjosrccomau:POWER_BI_PRO            5           0            5            
#banjosrccomau:WINDOWS_STORE           0           0            0            
#banjosrccomau:FLOW_FREE               10000       0            21           
#banjosrccomau:PHONESYSTEM_VIRTUALUSER 5           0            2            
#banjosrccomau:POWERAPPS_VIRAL         10000       0            0            
#banjosrccomau:EXCHANGESTANDARD        28          0            28           
#banjosrccomau:MS_TEAMS_IW             0           500000       1            
#banjosrccomau:O365_BUSINESS_PREMIUM   58          0            35           
#banjosrccomau:POWER_BI_STANDARD       1000000     0            30           
#banjosrccomau:MCOPSTNC                10000000    0            1            
#banjosrccomau:MCOPSTNEAU2             3           0            3            
#banjosrccomau:AX7_USER_TRIAL          10000       0            3            
#banjosrccomau:TEAMS_COMMERCIAL_TRIAL  500000      0            2   

$Credentials = Get-Credential
Connect-MsolService -Credential $credentials

#Add the SKU id you want to add license for
$SKU = "banjosrccomau:ENTERPRISEPREMIUM"
#Filename is the csv with user list heading UPN
$Filename = "C:\Temp\Banjosuserlist.csv"


    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        Get-Msoluser -UserPrincipalName $upn | select UserPrincipalName,UsageLocation,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},DisplayName | export-csv "C:\temp\banjospre-licenses.csv" -Append -NoTypeInformation
        #Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU"
        #Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $SKU -Verbose -RemoveLicenses "banjosrccomau:O365_BUSINESS_PREMIUM"
        Get-Msoluser -UserPrincipalName $upn | select UserPrincipalName,UsageLocation,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},DisplayName | export-csv "C:\temp\banjospost-licenses.csv" -Append -NoTypeInformation
    } 

