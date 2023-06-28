Param(
    [string] $DomainName            # e.g "callndev.onmicrosoft.com"  
)

if ([String]::IsNullOrEmpty($DomainName) -eq $true) 
{
    Write-Output "Usage: .\RemoveRecordingPolicy -domainName `"callndev.onmicrosoft.com`""
    exit(-1)
}

$securityGroupName="MS Teams Dubber Recording Group"
$policyName="Dubber" + $DomainName + "RP"
$policyDescription="MS Teams Dubber Recording Policy" 

Write-Output "Removing Users From Recording Policy"

$users = get-csonlineuser | Select ObjectId, TeamsComplianceRecordingPolicy
Foreach($user in $users)
{
    if (![string]::IsNullOrEmpty($user.TeamsComplianceRecordingPolicy))
    {
        Grant-CsTeamsComplianceRecordingPolicy -Identity $user.ObjectId -PolicyName $null
    }
}

Write-Output "Remove policy from group"
$recordingGroup = Get-AzureADGroup -All $True | Where-Object {$_.DisplayName -eq $securityGroupName} | Select -First 1 
if ($recordingGroup -ne $null)
{
    Remove-CsGroupPolicyAssignment -GroupId $recordingGroup.ObjectId -PolicyType TeamsComplianceRecordingPolicy -ErrorAction SilentlyContinue
}

Write-Output "Remove policy"
$complianceRecordingPolicies = Get-CsTeamsComplianceRecordingPolicy -ErrorAction SilentlyContinue | select Identity 
Foreach ($compliancePolicy in $complianceRecordingPolicies)
{
    $currentPolicyIdentity = $compliancePolicy.Identity
    if ($currentPolicyIdentity.Contains($PolicyName) -eq $True)
    {
        Remove-CsTeamsComplianceRecordingPolicy -Identity $compliancePolicy.Identity
        Write-Output "Removing Compliance Recording Policy $currentPolicyIdentity" 
    }
    else
    {
        Write-Output "Skipping Removal of Compliance Recording Policy $currentPolicyIdentity"

    }
}

Write-Output "Remove Group"
$recordingGroup = Get-AzureADGroup -All $True | Where-Object {$_.DisplayName -eq $securityGroupName} | Select -First 1
if ($recordingGroup -ne $null)
{
    Remove-AzureADGroup -ObjectId $recordingGroup.ObjectId
}

#Write-Output "Remove Online Application Instance"

#$onlineApplicationInstance = Get-CsOnlineApplicationInstance -Identity $botEmail
#if ($onlineApplicationInstance -ne $null)
#{
    #Remove-CsOnlineApplicationInstanceAssociation -Identities $botEmail
#}
