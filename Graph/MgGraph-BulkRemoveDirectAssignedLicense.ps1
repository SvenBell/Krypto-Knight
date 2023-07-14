<#
  Modified version of mrik23's MSOL-BulkRemoveDirectAssignedLicense.ps1 (https://gist.github.com/mrik23/2ed37ce0c7c4a79605bdcf052e29b391)
  MSOL-BulkRemoveDirectAssignedLicense.ps1 was a modified version of a script from Microsoft Documentation.
  Ref: https://docs.microsoft.com/en-us/azure/active-directory/active-directory-licensing-ps-examples
  Removed the part that checks if the users is assigned more products than the group assigned license.
  Added connection part and help to find Sku and Group Object ID.
  This script requires the Microsoft Graph (MgGraph) PowerShell module.
#>

Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.Read.All", "Organization.Read.All"

# Get License SKUs (SkuIds) for the tenant
Get-MgSubscribedSku -Property SkuPartNumber,SkuId | Select SkuPartNumber,SkuId

# The license SkuId to be removed (from output of Get-MgSubscribedSku above)
# URL to find friendly name: https://learn.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference
#$skuId = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46" #Biz Prem
#$skuId = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"  #Biz Std
#$skuId = "05e9a617-0261-4cee-bb44-138d3ef5d965"  #M365 E3
#$skuId = "6634e0ce-1a9f-428c-a498-f84ec7b8aa2e"  #Office 365 E2
$skuId = "6fd2c87f-b296-42f0-b197-1e91e994b900"  #Office 365 E3
	

# The NAME of the Azure AD group with license assignment to be processed
#$LicensedGroup = "Microsoft365BizPremCloudSub"
#$LicensedGroup = "Microsoft365BizStdCloudSub"
#$LicensedGroup = "MicrosoftOffice365E2CloudSub"
$LicensedGroup = "MicrosoftOffice365E3CloudSub"

# Get the group Object ID
$groupId = (Get-MgGroup -Filter "DisplayName eq `'$LicensedGroup`'").Id

# Helper functions used by the script

# Returns TRUE if the user has the license assigned directly
function UserHasLicenseAssignedDirectly {
    Param($user, $skuId)
    $license = GetUserLicense $user $skuId
    if ($license -ne $null) {
        # GroupsAssigningLicense contains a collection of IDs of objects assigning the license
        # This could be a group object or a user object (contrary to what the name suggests)
        # If the collection is empty, this means the license is assigned directly - this is the case for users who have never been licensed via groups in the past
        if (@($license.AssignedByGroup).Count -ne @($license.AssignedByGroup | ?{$_ -ne $null}).Count) {
            return $true
        }

        # If the collection contains the ID of the user object, this means the license is assigned directly
        # Note: the license may also be assigned through one or more groups in addition to being assigned directly
        foreach ($assignmentSource in $license.AssignedByGroup) {
            if ($assignmentSource -ieq $user.Id) {
                return $true
            }
        }
        return $false
    }
    return $false
}

# Returns TRUE if the user is inheriting the license from a specific group
function UserHasLicenseAssignedFromThisGroup {
    Param($user, $skuId, $groupId)
    $license = GetUserLicense $user $skuId
    if ($license -ne $null) {
        # GroupsAssigningLicense contains a collection of IDs of objects assigning the license
        # This could be a group object or a user object (contrary to what the name suggests)
        foreach ($assignmentSource in $license.AssignedByGroup) {
            # If the collection contains at least one ID not matching the user ID this means that the license is inherited from a group.
            # Note: the license may also be assigned directly in addition to being inherited
            if ($assignmentSource -ieq $groupId) {
                return $true
            }
        }
        return $false
    }
    return $false
}

# Returns the license object corresponding to the skuId. Returns NULL if not found
function GetUserLicense {
    Param($user, $skuId)
    # We look for the specific license SKU in all licenses assigned to the user
    foreach($license in $user.AssignedLicenses) {
        if ($license.SkuId -ieq $skuId) {
            return $user.LicenseAssignmentStates | ?{ $_.SkuId -eq $skuId }
        }
    }
    return $null
}

# Process staging removal for only 20 members in the group first
# You can then process all members in the group if the result of staging is OK - replace "-Top 20" with "-All"
#$groupMembers = Get-MgGroupMember -Top 20 -GroupId $groupId | %{ Get-MgUser -UserId $_.Id -Property UserPrincipalName,Id,AssignedLicenses,LicenseAssignmentStates }
$groupMembers = Get-MgGroupMember -All -GroupId $groupId | %{ Get-MgUser -UserId $_.Id -Property UserPrincipalName,Id,AssignedLicenses,LicenseAssignmentStates }
$groupMembers |
    Foreach { 
        $user = $_;
        $operationResult = "";

        # Check if Direct license exists on the user
        if (UserHasLicenseAssignedDirectly $user $skuId)
        {
            # Check if the license is assigned from this group, as expected
            if (UserHasLicenseAssignedFromThisGroup $user $skuId $groupId)
            {

                    # Remove the direct license from user
                    Set-MgUserLicense -UserId $user.UserPrincipalName -AddLicenses @{} -RemoveLicenses $skuId | Out-Null
                    $operationResult = "Removed direct license from user."   

            }
            else
            {
                $operationResult = "User does not inherit this license from this group. License removal was skipped."
            }
        }
        else
        {
            $operationResult = "User has no direct license to remove. Skipping."
        }

        # Format output
        New-Object Object | 
                    Add-Member -NotePropertyName UserId -NotePropertyValue $user.Id -PassThru |
                    Add-Member -NotePropertyName UserPrincipalName -NotePropertyValue $user.UserPrincipalName -PassThru |
                    Add-Member -NotePropertyName OperationResult -NotePropertyValue $operationResult -PassThru 
    } | Format-Table