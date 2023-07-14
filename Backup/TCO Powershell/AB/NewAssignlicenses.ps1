
#Install-Module Microsoft.Graph -Scope AllUsers

#Get-InstalledModule Microsoft.Graph

Connect-Graph -Scopes User.ReadWrite.All, Organization.Read.All

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
#CHANGE BELOW VARIABLES FOR EACH CUSTOMER
##############################################################################
$path = "C:\temp\license\"
$File = "EntagLicense.csv"
$export = "EntagLicense"
##############################################################################
$Filename = $path+$file
$exportprename = $path+$export+'-pre.csv'
$exportpostname = $path+$export+'-post.csv'

#$upn = "andrew.baird@entag.com.au"
$SKU1 = Get-MgSubscribedSku -All | Where-Object {$_.skuPartNumber -contains "MCOPSTNEAU2"} | select Skuid
$SKU2 = Get-MgSubscribedSku -All | Where-Object {$_.skuPartNumber -contains "MCOEV"} | select Skuid
$addLicenses = @(
    @{SkuId = $SKU1.SkuId},
    @{SkuId = $SKU2.SkuId}
    )

    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $upn= $user.UPN
        write-host "Assigning" $upn "licenses" -foregroundcolor Green
        #Get-MgUser -UserId $upn | select UserPrincipalName
        #Get-MgUserLicenseDetail -UserId $upn
        Set-MgUserLicense -UserId $upn -AddLicenses $addLicenses -RemoveLicenses @()
        #Get-MgUserLicenseDetail -UserId $upn | select SkuPartNumber | export-csv $exportpostname -Append -NoTypeInformation

    }

Disconnect-Graph