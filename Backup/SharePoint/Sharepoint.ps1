#$tenant = 'abacusals'
#$tenantId = '6682b8c8-95f5-4ebe-9225-076030c1983c'
$m = 'SharePointPnPPowerShellOnline'

import-module  SharePointPnPPowerShellOnline

$filename = "C:\temp\sites.csv" #Site Import CSV
$users = Import-Csv $FileName

#Connect-Pnponline https://abacusals.sharepoint.com/sites/Abacus-HIRF864 -SPOManagementShell
#Get-PnPSite
 

#update-Module SharePointPnPPowerShellOnline
function Load-SPO ($m) {
    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {

 

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m -Verbose
        }
        else {

 

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m -Verbose
            }
            else {

 

                # If module is not imported, not available and not in online gallery then abort
                write-host "Module $m not imported, not available and not in online gallery, exiting."
                EXIT 1
            }
        }
    }
}

 

$cred = Get-Credential

 


Foreach ($user in $users){
 
$tenant = 'abacusals'
$tenantId = '6682b8c8-95f5-4ebe-9225-076030c1983c'
$siteName = $user.SiteName #Sharepoint site name from CSVe
$docLib = $user.document #Sharepoint Document Library
$folder = $user.folder #SharePoint Folder\

 

 

#Connection
Connect-PnPOnline https://$tenant.sharepoint.com/sites/$siteName -SPOManagementShell
write-host https://$tenant.sharepoint.com/sites/$siteName -foregroundcolor Green
 

#Convert Tenant ID
$tenantId = $tenantId -replace '-','%2D'

 

#Convert Site ID
$PnPSite = Get-PnPSite -Includes "Id" | select id
$PnPSite = $PnPSite.Id -replace '-','%2D'
$PnPSite = '%7B' + $PnPSite + '%7D'

 

#Convert Web ID
$PnPWeb = Get-PnPWeb -Includes "Id" | select id
$PnPWeb = $PnPWeb.Id -replace '-','%2D'
$PnPWeb = '%7B' + $PnPWeb + '%7D'

 

#Convert List ID
$PnPList = Get-PnPList $docLib -Includes "Id" | select id
$PnPList = $PnPList.Id -replace '-','%2D'
$PnPList = '%7B' + $PnPList + '%7D'
$PnPList = $PnPList.toUpper()

#Convert Folder ID
$SiteFolder = $docLib + '\' + $folder
$PnPFolder = Get-PnPFolder -Url $SiteFolder -Includes "UniqueID" | Select UniqueID
$PnPFolder = $PnPFolder.Id -replace '-','%2D'
 

$FULLURL = 'tenantId=' + $tenantId + '&siteId=' + $PnPSite + '&webId=' + $PnPWeb + '&listId=' + $PnPList + '&folderId=' + $PnPFolder + '&webUrl=https%3A%2F%2F' + $tenant + '%2Esharepoint%2Ecom%2Fsites%2F' + $siteName + '&version=1'

#Write-Output 'List ID:'| Export-Csv -Path C:\temp\output.csv -Append
#select $FULLURL | Export-Csv -Path C:\temp\output.csv -Append
New-Object -TypeName PSCustomObject -Property @{
Site = $siteName
URL = $FULLURL
} | Export-Csv -Path C:\temp\output.csv -Append
}