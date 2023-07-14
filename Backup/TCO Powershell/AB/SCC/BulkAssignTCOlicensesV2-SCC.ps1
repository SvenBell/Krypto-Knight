﻿#Find the SKU id for TCO
Connect-MsolService
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


#$Credentials = Get-Credential
#Connect-MsolService -Credential $credentials

#Add the SKU id you want to add license for
#$SKU1 = "anilroychoudhrycorumcom:MCOEV_TELSTRA"
#$SKU2 = "anilroychoudhrycorumcom:MCOPSTNEAU2"
$SKU1 = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "MCOPSTNEAU2"} | select AccountSkuid
$SKU2 = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "MCOEV"} | select AccountSkuid
#Filename is the csv with user list heading UPN
$Filename = "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\Sunshine Coast Council\0. SSC - TELECOMMUNICATIONS PROJECT\Streams\TCO\Pre-cutovers\May2022-PilotUsers-Batch8-User.csv"


    $users = Import-Csv $FileName
#    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU"
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $SKU2.AccountSkuId -Verbose
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $SKU1.AccountSkuId -Verbose 
    } 

