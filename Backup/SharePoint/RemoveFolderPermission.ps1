#Set Variables
$SiteURL = "https://entag.sharepoint.com/sites/MAINSITE"
  
#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin

#Array of Sites to loop over and purge permissions on Folders in each Library
$sites = @( "Site Title 1",
            "Site Title 2",
            "..."
            )
Foreach ($site in $sites){
 
#Get all list items in batches
write-host "Fixing Permissions in $site"
 
#Get all list items in batches
$ListItems = Get-PnPListItem -List $site -PageSize 500
 
#Iterate through each list item
ForEach($ListItem in $ListItems)
{
    #Check if the Item has unique permissions
    $pipe = "checking the file" + $ListItem.FieldValues["FileLeafRef"]
    Write-host $pipe

    $HasUniquePermissions = Get-PnPProperty -ClientObject $ListItem -Property "HasUniqueRoleAssignments"
    If($HasUniquePermissions)
    {        
        $Msg = "Deleting Unique Permissions on {0} '{1}' at {2} " -f $ListItem.FileSystemObjectType,$ListItem.FieldValues["FileLeafRef"],$ListItem.FieldValues["FileRef"]
        Write-host $Msg
        #Delete unique permissions on the list item
        Set-PnPListItemPermission -List $ListName -Identity $ListItem.ID -InheritPermissions
    }
}
}
