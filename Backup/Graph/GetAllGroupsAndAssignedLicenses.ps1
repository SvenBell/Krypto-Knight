# Import the Microsoft.Graph.Groups module
Import-Module Microsoft.Graph.Groups
#Connect-MgGraph
#Get-MgContext
# Get all groups and licenses
#$groups = Get-MgGroup -All
$groups = Get-MgGroup -ConsistencyLevel eventual -Search '"DisplayName:Microsoft"'
$groupsWithLicenses = @()
# Loop through each group and check if it has any licenses assigned
foreach ($group in $groups) {
    $licenses = Get-MgGroup -GroupId $group.Id -Property "AssignedLicenses, Id, DisplayName" | Select-Object AssignedLicenses, DisplayName, Id
    if ($licenses.AssignedLicenses) {
        $groupData = [PSCustomObject]@{
            ObjectId = $group.Id
            DisplayName = $group.DisplayName
            Licenses = $licenses.AssignedLicenses
        }
        $groupsWithLicenses += $groupData
    }
}
$groupsWithLicenses