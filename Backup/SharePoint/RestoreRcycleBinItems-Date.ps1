#Parameter
$SiteURL= "https://hrlgroup.sharepoint.com/sites/SITENAME"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Credentials (Get-Credential)
 
#Get All Items Deleted in the Past 7 Days
$DeletedItems = Get-PnPRecycleBinItem | Where { $_.DeletedDate -gt (Get-Date).AddDays(-2) }

write-host $DeletedItems
 
#Restore Recycle bin items matching given query
$DeletedItems | Restore-PnpRecycleBinItem -Force

