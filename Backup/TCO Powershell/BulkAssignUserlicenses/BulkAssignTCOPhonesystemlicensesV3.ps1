﻿#14/06/2021 Andrew Baird
#20/07/2021 Enhanced by Stephen Bell
#Reach out if there are any issues or refinements needed
#
#Leaving the get license sku command and result here as handy to be aware of what you are search for in the where-objects used later on
#
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
#   
##########################################################
#Variables to be changed to suit each customer
$path = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\THE BMD GROUP\TCO Project Docs\Customer Facing_Link_Shared\Migration Sheets\"
$File = "USERLIST_License_Exclude7000_20210720.csv"

##########################################################
$Filename = $path+$file    
#
#

#$Credentials = Get-Credential

#Connect-MsolService
# -Credential $credentials

#Add the SKU id you want to add license for
#If you have issues with contain you can replace with -like if needed
$phonesystemsku = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "MCOEV"} | select AccountSkuid
$TCOSKU = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "MCOPSTNEAU2"} | select AccountSkuid
#Command doesn't like the combined license variable so had to remove and add a seperate line in the for each loop
#$Combinedlicense = $TCOSKU.AccountSkuId + "," + $phonesystemsku.AccountSkuId
#Filename is the csv with user list heading UPN



    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $upn= $user.UPN
        Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU" -ErrorAction SilentlyContinue
            if($? -ne 'False')
    {
    write-host 'UPN setting location' $upn -ForegroundColor Red
    write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor DarkRed}
    else{
    #Display line to track progress through foreach loop
        write-host 'Set UPN' $upn 'to Location Australia' -ForegroundColor Blue
        #Assign Phone System license to user
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $phonesystemsku.AccountSkuId -ErrorAction SilentlyContinue
        #Assign Telstra Calling Plan to user
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $TCOSKU.AccountSkuId -ErrorAction SilentlyContinue
        if($? -ne 'true')
    {
    write-host 'UPN assigning license' $upn -ForegroundColor Red
    write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor DarkRed}
    else{
        Write-host 'Assigned licenses to' $upn -ForegroundColor Green 
    } } }

#Get-PSSession | Remove-PSSession
