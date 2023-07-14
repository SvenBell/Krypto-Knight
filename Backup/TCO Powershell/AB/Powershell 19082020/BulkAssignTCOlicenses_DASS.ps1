#Find the SKU id for TCO
$credential = Get-Credential
Connect-MsolService -Credential $credential
get-MsolAccountSku
#Example
#AccountSkuId                            ActiveUnits WarningUnits ConsumedUnits
#------------                            ----------- ------------ -------------
#reseller-account:FLOW_FREE              10000       0            8            
#reseller-account:MCOCAP                 25          0            1            
#reseller-account:MCOPSTNEAU2            91          0            26           
#reseller-account:SPE_E5                 87          0            84           
#reseller-account:TEAMS_COMMERCIAL_TRIAL 500000      0            0            
#reseller-account:RIGHTSMANAGEMENT_ADHOC 10000       0            1            
#reseller-account:STANDARDPACK           20          0            17        


$Credentials = Get-Credential
Connect-MsolService -Credential $credentials

#Add the SKU id you want to add license for
$SKUTCO = "mercproperty:MCOPSTNEAU2"
#$SKUphone = "reseller-account:MCOEV"
#$SKUE3 = "reseller-account:ENTERPRISEPACK"
#Filename is the csv with user list heading UPN
$Filename = "C:\Temp\Mercuserlist_05022020.csv"


    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU"
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $SKUTCO  -Verbose
        Write-host $upn 
    } 

    #$error[0]
    #$Error | Format-List -Force

        $credentials = Get-Credential
        Connect-MsolService -Credential $credentials
        Set-MsolUser -UserPrincipalName tv-meetingrm@ncphn.org.au -UsageLocation "AU"
        Set-MsolUserLicense -UserPrincipalName tv-meetingrm@ncphn.org.au -AddLicenses reseller-account:MCOCAP, reseller-account:MCOPSTNEAU2 -Verbose




        Import-Module SkypeOnlineConnector
        Connect-MsolService -Credential $credentials
        $sfboSession = New-CsOnlineSession
        Import-PSSession $sfboSession

        Set-CsOnlineVoiceUser -id tv-meetingrm@ncphn.org.au -TelephoneNumber +61755890519

        Remove-PSSession $sfboSession