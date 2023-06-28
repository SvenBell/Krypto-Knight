#Find the SKU id
#get-MsolAccountSku
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
##################################################
#Change for each customer
#Filename is the csv with user list heading aadisplayname using resouce account display name
$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\Bulk things\BulkResourceaccount-Weareco.csv"



$Credentials = Get-Credential
Connect-MsolService -Credential $credentials
#Finds the virtualusersku name this changes with different tenancies
$virtualusersku = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"} | select AccountSkuid



    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $displayname = $user.aadisplayname
        #$upn = GET-MSOLUSER -SEARCHSTRING $displayname | SELECT-OBJECT USERPRINCIPALNAME
        $upn = Get-msoluser | Where-Object {$_.Displayname -eq "$displayname"} | select UserprincipalName
        Set-MsolUser -UserPrincipalName $upn.UserPrincipalName -UsageLocation "AU"
        Set-MsolUserLicense -UserPrincipalName $upn.UserPrincipalName -AddLicenses $virtualusersku.AccountSkuId -Verbose
        write-host "Assigning" $virtualusersku.AccountSkuId "license to" $displayname $upn.UserPrincipalName -foregroundcolor Green
    } 


