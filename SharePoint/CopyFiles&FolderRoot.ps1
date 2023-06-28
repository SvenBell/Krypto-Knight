#SharePoint PNP
Install-Module SharePointPnPPowerShellOnline

$CSV = "C:/temp/DataMapping.csv"
$SharePointSites = Import-csv $CSV

ForEach ($SharePointSite in $SharePointSites)
{

#Parameters
$SiteURL = $SharePointSite.SiteURL
$SourceFolderURL = $SharePointSite.SourceFolderURL
$TargetFolderURL = $SharePointSite.destination

#Query for Folders
$QueryFolders = "<View><Query><Where><Eq><FieldRef Name='FSObjType' /><Value Type=’Integer’>1</Value></Eq></Where></Query></View>"

#Query for Files
$QueryFiles = "<View><Query><Where><Eq><FieldRef Name='FSObjType' /><Value Type=’Integer’>0</Value></Eq></Where></Query></View>"
  
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin

#file search
$RootFiles = Get-PnpListItem -List $SourceFolderURL -Query $QueryFiles
ForEach($RootFile in $RootFiles)
{

$filename = $RootFile["FileLeafRef"] | Out-string
Write-Host "$($SoureFolderURL)\$($filename)"

Copy-PnPFile -SourceUrl "$($SoureFolderURL)\$($filename)" -TargetUrl $TargetFolderURL -skipSourceFolderName -OverwriteIfAlreadyExists -force
}

#Search for Folders
$RootFolders = Get-PnpListItem -list $SourceFolderURL -Query $QueryFolders
ForEach($RootFolder in $RootFolders)
{

$foldername = $RootFolder["FileLeafRef"] | Out-String

Write-Host "$($SourceFolderURL)\$($foldername)"

Copy-PnPFile -SourceUrl "$($SourceFolderURL)\$($foldername)" -TargetUrl $TargetFolderURL -skipSourceFolderName -OverwriteIfAlreadyExists -force
}
}
