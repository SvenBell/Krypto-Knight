Install-Module -Name AzureAD -Force

Connect-AzureAD

#List the license plans in tenant
Get-AzureADSubscribedSku | Select SkuPartNumber




$SKUTCO = (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -like 'MCOPSTNEAU2'}).skuid
$SKUPhone = (Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -like 'MCOEV*'}).skuid
$Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses 
# add the previously created license SKU as something to be added 
$Licenses.AddLicenses = $License

#Filename is the csv with user list heading UPN
$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\SCC\SCCpilot-Venue114-A.csv"

    $users = Import-Csv $FileName
#    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
#Set user location to Australia
Set-AzureADUser -ObjectID $UPN -UsageLocation "AU"
Set-AzureADUserLicense -ObjectId $UPN -AssignedLicenses $SKUTCO
Set-AzureADUserLicense -ObjectId $UPN -AssignedLicenses $SKUPhone
}

Disconnect-AzureAD