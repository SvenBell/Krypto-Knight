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
#$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\Bulk things\BulkResourceaccount-Weareco.csv"



$Credentials = Get-Credential
Connect-MsolService -Credential $credentials
#Finds the virtualusersku name this changes with different tenancies
$virtualusersku = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"} | select AccountSkuid
$usagelocation = "AU"
$aaname = GET-MSOLUSER -SEARCHSTRING AA- | Where-Object {$_.isLicensed -like "False"} | select displayname, UserPrincipalName 
$aaname | ForEach-Object {
Set-MsolUser -UserPrincipalName $_.UserPrincipalName -UsageLocation $UsageLocation
Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses $virtualusersku.AccountSkuId
write-host "Assigning" $virtualusersku.AccountSkuId "license to" $_.displayname -foregroundcolor Green
}



