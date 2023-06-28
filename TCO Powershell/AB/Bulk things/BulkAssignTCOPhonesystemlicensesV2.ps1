#Find the SKU id for TCO
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


$Credentials = Get-Credential
Connect-MsolService -Credential $credentials

#Add the SKU id you want to add license for
$TCOSKU = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "MCOPSTNEAU2"} | select AccountSkuid
$phonesystemsku = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "MCOEV"} | select AccountSkuid
#$Combinedlicense = $TCOSKU.AccountSkuId + "," + $phonesystemsku.AccountSkuId
#Filename is the csv with user list heading UPN
$path = "C:\Users\AndrewBaird\TShopBiz & Entag Group\Projects - Customer Projects\OXWORKS\LD8523- TCO Deployment\TCO project docs\Powershell WORKING files\"
$File = "V-DandenongUsers.csv"
$Filename = $path+$file 


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
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $phonesystemsku.AccountSkuId -ErrorAction SilentlyContinue
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $TCOSKU.AccountSkuId -ErrorAction SilentlyContinue
        if($? -ne 'true')
    {
    write-host 'UPN assigning license' $upn -ForegroundColor Red
    write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor DarkRed}
    else{
        Write-host 'Assigned licenses to' $upn -ForegroundColor Green 
    } } }

Get-PSSession | Remove-PSSession
