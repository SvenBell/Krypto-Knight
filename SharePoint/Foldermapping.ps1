  
#module Install powers
Write-Host "Installing Required PowerShellue"
Install-Module SharePointPnPPowerShellOnline

#Set Parameter
$TenantSiteURL="https://<domain>.sharepoint.com"
$FolderDir = "C:\temp"
 
#Connect to the Tenant site
Connect-PnPOnline $TenantSiteURL -UseWebLogin
 
#Get all site collections
$sites = Get-PnPTenantSite

Foreach ($site in $sites) {

write-host Starting Folder Mapping on $site.Title
Write-Host $site.Url

$SiteURL = $site.Url
$SiteName = $site.Title

#Output Files
$ReportFile="$FolderDir\$SiteName-Foldermapping.csv"

#Connect to SPO
Connect-PnPOnline -Url $SiteURL
#Target multiple lists 
$allLists = Get-PnPList | Where-Object {$_.BaseTemplate -eq 101}
#Store the results
$results = @()
foreach ($row in $allLists) {
    $allItems = Get-PnPListItem -List $row.Title -Fields "FileLeafRef", "SMTotalFileStreamSize", "FileDirRef", "FolderChildCount", "ItemChildCount"
    
    foreach ($item in $allItems) {
        if (($item.FileSystemObjectType) -eq "Folder") {
            $results += New-Object psobject -Property @{
                FileType          = $item.FileSystemObjectType 
                RootFolder        = $item["FileDirRef"] 
                LibraryName       = $row.Title
                FolderName        = $item["FileLeafRef"]
                FullPath          = $item["FileRef"]
                FolderSizeInMB    = ($item["SMTotalFileStreamSize"] / 1MB).ToString("N")
                NbOfNestedFolders = $item["FolderChildCount"]
                NbOfFiles         = $item["ItemChildCount"]
            }
        }
    }
}
#Export the results
$results | Export-Csv -Path $ReportFile -NoTypeInformation

}
