#./DubberCreateRecordingPolicy.ps1 -portal uk1_portal -domain "callndev.onmicrosoft.com" -adminEmail "vo@callndev.onmicrosoft.com" -recordedUsersFilename ".\EmailsToRecord.txt"
#./DubberCreateRecordingPolicy.ps1 -portal dev_portal -domain "chipwillman.onmicrosoft.com" -adminEmail "chip@chipwillman.onmicrosoft.com" -recordedUsersFilename ".\EmailsToRecord.txt" -noRecordingNotification $True"
Param(
    [string] $Portal,               # e.g "uk1_portal"
    [string] $DomainName,               # e.g "callndev.onmicrosoft.com"  
    [string] $AdminEmail,           # e.g "vo@callndev.onmicrosoft.com"
    [string] $RecordedUsersFilename, # e.g ".\EmailsToRecord.txt" 
    [Boolean] $DisableCallsWhenRecordersDown = $False, #
    [UInt32] $ConcurrentInvitationCount = 1, # The Teams server will issue multiple invitations to each HA cluster.  Dubber uses Paired recording applications to achieve this and recommends this values remain 1
    [Boolean] $NoRecordingNotifications = $False
)

$botApplicationIdA = ""
$botApplicationIdB = ""
$botNameA = "DubberBotA" + $Portal# + $Domain + "A"
$botNameB = "DubberBotB" + $Portal# + $Domain + "B"
$BotEmailA = "dubberbotA" + $Portal + "@" + $DomainName 
$BotEmailB = "dubberbotB" + $Portal + "@" + $DomainName 

if ([String]::IsNullOrEmpty($Portal) -eq $true -or [String]::IsNullOrEmpty($DomainName) -eq $true -or [String]::IsNullOrEmpty($AdminEmail) -eq $true)
{
    Write-Output "Usage: ./DubberCreateRecordingPolicy -portal uk1_portal -domainName `"callndev.onmicrosoft.com`" -adminEmail `"vo@callndev.onmicrosoft.com`" [-recordedUsersFilename `".\EmailsToRecord.txt`"] [-DisableCallsWhenRecordersDown $True] [-ConcurrentInvitationCount=1] [-noRecordingNotification $True]"
    exit(-1)
}

if ($Portal -eq "dev_portal")
{
    $botApplicationIdA = "261a0176-e1f9-45db-be35-a7a97ba56b6e" 
    $botApplicationIdB = "40b88eba-6ae1-4ca2-9341-7899bf94794a" 
}
if ($Portal -eq "us_portal")
{
    $botApplicationIdA = "09d28449-cc82-488c-867a-c3478b981114"
    $botApplicationIdB = "afcc04f8-a3bf-4ae0-9f14-75e89135f978"
}
if ($Portal -eq "eu_portal")
{
    $botApplicationIdA = "b2117b85-bbe0-47e8-ae3c-90d9b0227c73"
    $botApplicationIdB = "a2831612-b3e1-4b1f-b089-be00e2ae7e0a"
}
if ($Portal -eq "uk1_portal")
{
    $botApplicationIdA = "933eff3b-9ef9-451a-806a-4fb10cd4c742"
    $botApplicationIdB = "4683eb1f-b8d2-41a5-9379-ef2a22d57cc6"
}
if ($Portal -eq "uat_portal")
{
    $botApplicationIdA = "78ccfac0-c445-4563-bd60-88c0b4929dab"
    $botApplicationIdB = "03e4b1bc-cfad-4d40-adcd-ef297dbb2f36"
}
if ($Portal -eq "stg_portal")
{
    $botApplicationIdA = "680038e9-b3e1-44a4-8456-6df8c1235f13"
    $botApplicationIdB = "8ea68c8d-3a8e-4244-abcd-02605484d025"
}
if ($Portal -eq "sbox_portal")
{
    $botApplicationIdA = "411a7fb0-7af5-4000-b12e-88ee18a76be8"
    $botApplicationIdB = "1ba1c0bb-7b11-4f0b-814b-ead5141e267d"
}
if ($Portal -eq "ca_portal")
{
    $botApplicationIdA = "5c2883f9-3027-42e2-8f3a-3afecd346bd7"
    $botApplicationIdB = "c0348e0f-379e-49ff-b7d3-3b1b095098a6"
}
if ($Portal -eq "au_portal")
{
    $botApplicationIdA = "dbbdef81-7774-4454-9d22-ce2b3f14e5e0"
    $botApplicationIdB = "8d05765e-a644-4326-a7b6-5f484d376a37"
}
if ($Portal -eq "sg_portal")
{
    $botApplicationIdA = "2a472682-d3d8-4216-b331-62d764724530"
    $botApplicationIdB = "ea6ec76a-c491-439d-b8fb-6e310277f5a2"
}
if ($Portal -eq "jp_portal")
{
    $botApplicationIdA = "144e607b-4201-4cef-a6df-1a2590ce5750"
    $botApplicationIdB = "98ef1a62-9174-488f-808d-1efde9361306"
}
if ($Portal -eq "uk_portal")
{
    $botApplicationIdA = "ec91a1d4-dae6-479e-88d7-1800aecf969b"
    $botApplicationIdB = "06bf6b86-607a-422f-8fc0-46daa93c5c6c"
}

if ($botApplicationIdA -eq "")
{
    Write-Output "The portal $Portal does not exist"
    Write-Output "Available Portals:"
    Write-Output "au_portal"
    Write-Output "ca_portal"
    Write-Output "eu_portal"
    Write-Output "jp_portal"
    Write-Output "sg_portal"
    Write-Output "us_portal"
    Write-Output "uk_portal (Ireland)"
    Write-Output "uk1_portal (London)"
    Write-Output "dev_portal"
    Write-Output "uat_portal"
    Write-Output "stg_portal"
    Write-Output "sbox_portal"
    exit(-1)
}

$NoRecordingAnnounementFlag = ""
if ($NoRecordingNotifications -eq $True)
{
    $NoRecordingAnnounementFlag = ".NA"
}

$securityGroupName="MS Teams Dubber Recording Group"
$policyName="Dubber" + $DomainName + "RP" + $NoRecordingAnnounementFlag
$policyDescription="MS Teams Dubber Recording Policy" 

$outputFilename= $DomainName + "registration.txt"

Write-Output "Get Recording Online Application Instance"
#Create new application instance

$onlineApplicationInstance = Get-CsOnlineApplicationInstance -Identity $botEmailA -ErrorAction SilentlyContinue | Select -First 1
if ($onlineApplicationInstance -eq $null)
{
	Write-Output "Create Online Application Instance 1"
    $onlineApplicationInstance = New-CsOnlineApplicationInstance -UserPrincipalName $botEmailA -DisplayName $botNameA -ApplicationId $botApplicationIdA
}
else
{
	Write-Output "Online Application Instance 1 exists"
}

# Extract tenantId and objectId from previous result
$tenantIdA = $onlineApplicationInstance.TenantId
$objectIdA = $onlineApplicationInstance.ObjectId
Write-Output "Sync Online Application Instance to Active Directory"
Sync-CsOnlineApplicationInstance -ObjectId $objectIdA


if (![string]::IsNullOrEmpty($botApplicationIdB))
{
    $onlineApplicationInstanceB = Get-CsOnlineApplicationInstance -Identity $botEmailB -ErrorAction SilentlyContinue  | Select -First 1
    if ($onlineApplicationInstanceB -eq $null)
    {
	    Write-Output "Create Online Application Instance 1"
        $onlineApplicationInstanceB = New-CsOnlineApplicationInstance -UserPrincipalName $botEmailB -DisplayName $botNameB -ApplicationId $botApplicationIdB
    }
    else
    {
	    Write-Output "Online Application B Instance 2 exists"
    }
    # Extract tenantId and objectId from previous result
    $tenantIdB = $onlineApplicationInstanceB.TenantId
    $objectIdB = $onlineApplicationInstanceB.ObjectId

    Write-Output "Sync Online Application Instance to Active Directory"
    Sync-CsOnlineApplicationInstance -ObjectId $objectIdB
}
else
{
    $onlineApplicationInstanceB = $null
    Write-Output "Environment configured for 1 recorder"
}

$recordingGroup = Get-AzureADGroup -All $True | Where-Object {$_.DisplayName -eq $securityGroupName} | Select -First 1
if ($recordingGroup -eq $null)
{
	Write-Output "Create $securityGroupName in Active Directory"
    $recordingGroup = New-AzureADGroup -Description $securityGroupName -DisplayName $securityGroupName -MailEnabled $false -SecurityEnabled $true -MailNickName "msteamsrecording"
    Start-Sleep -Seconds 15
}
else
{
	Write-Output "$securityGroupName exists in Active Directory"
}

$complianceRecordingPolicy = Get-CsTeamsComplianceRecordingPolicy -Identity $policyName -ErrorAction SilentlyContinue | Select -First 1
if ($complianceRecordingPolicy -eq $null)
{
	Write-Output "Create Compliance Recording Policy"
	New-CsTeamsComplianceRecordingPolicy -Tenant $tenantIdA -Enabled $true -Description $policyDescription $policyName

    $complianceRecordingApplication = Get-CsTeamsComplianceRecordingApplication -Id $objectId -ErrorAction SilentlyContinue
	#create compliance recording policy
    if ($complianceRecordingApplication -eq $null)
    {
        $complianceRecordingApplication = New-CsTeamsComplianceRecordingApplication -Tenant $tenantIdA -Parent $policyName -Id $objectIdA -RequiredBeforeMeetingJoin $DisableCallsWhenRecordersDown -RequiredDuringMeeting $DisableCallsWhenRecordersDown -RequiredBeforeCallEstablishment $DisableCallsWhenRecordersDown -RequiredDuringCall $DisableCallsWhenRecordersDown -ConcurrentInvitationCount $ConcurrentInvitationCount
    }

    if (![string]::IsNullOrEmpty($botApplicationIdB))
    {
        $complianceRecordingApplicationB = Get-CsTeamsComplianceRecordingApplication -Id $objectIdB -ErrorAction SilentlyContinue
	    #create compliance recording policy
        if ($complianceRecordingApplicationB -eq $null)
        {
            $complianceRecordingApplicationB = New-CsTeamsComplianceRecordingApplication -Tenant $tenantIdB -Parent $policyName -Id $objectIdB -RequiredBeforeMeetingJoin $DisableCallsWhenRecordersDown -RequiredDuringMeeting $DisableCallsWhenRecordersDown -RequiredBeforeCallEstablishment $DisableCallsWhenRecordersDown -RequiredDuringCall $DisableCallsWhenRecordersDown -ConcurrentInvitationCount $ConcurrentInvitationCount
        }
    	Set-CsTeamsComplianceRecordingPolicy -Tenant $tenantIdA -Identity $policyName -ComplianceRecordingApplications @($complianceRecordingApplication, $complianceRecordingApplicationB)
    }
    else
    {
    	Set-CsTeamsComplianceRecordingPolicy -Tenant $tenantIdA -Identity $policyName -ComplianceRecordingApplications @($complianceRecordingApplication)
    }
	#Grant policy by user
	#Write-Output "Grant Compliance Recording Policy by Admin"
	#Grant-CsTeamsComplianceRecordingPolicy -Identity $AdminEmail -PolicyName $policyName -Tenant $tenantId
    Start-Sleep -Seconds 15

    $complianceRecordingPolicy = Get-CsTeamsComplianceRecordingPolicy -Identity $policyName | Select -First 1
}
else
{
	Write-Output "Compliance Recording Policy Exists"
}

#Assign recording policy to group
$groupPolicyAssignment = Get-CsGroupPolicyAssignment -PolicyType TeamsComplianceRecordingPolicy 
if ($groupPolicyAssignment.Length -eq 0)
{
    Write-Output "Assign policy to group"
    New-CsGroupPolicyAssignment -GroupId $recordingGroup.ObjectId -PolicyType TeamsComplianceRecordingPolicy -PolicyName $complianceRecordingPolicy.Identity -Rank 1
}
else
{
    Write-Output "Group Policy Assignment exists"
}

if ([string]::IsNullOrEmpty($recordedUsersFilename))
{
    Write-Output "No user file supplied.  Use -recordedUsersFilename <filename>.txt"
}
else
{
    if (![System.IO.File]::Exists($recordedUsersFilename))
    {
        $recordedUsersFilename = (Get-Location).Path + "/" + $recordedUsersFilename
    }

    if (![System.IO.File]::Exists($recordedUsersFilename))
    {
        Write-Output "The file $recordedUsersFilename does not exist"
    }
    else
    {
        $groupMembers = Get-AzureADGroupMember -ObjectId $recordingGroup.ObjectId
        $lines = [System.IO.File]::ReadAllLines($recordedUsersFilename)
        Foreach($emailAddress in $lines)
        {
            $addUser = $True
            Foreach($existingUser in $groupMembers)
            {
                if ($existingUser.UserPrincipalName -eq $emailAddress)
                {
                    $addUser = $False
                    break
                }
            }
            if ($addUser)
            {
                $userToAdd = Get-CSOnlineUser -Identity $emailAddress
        	    Add-AzureAdGroupMember -ObjectId $recordingGroup.ObjectId -RefObjectId $userToAdd.ObjectId -ErrorAction SilentlyContinue
            }
        }
    }
}

start-process ("https://login.microsoftonline.com/" + $tenantIdA + "/adminconsent?client_id=" + $BotApplicationIdA)
Write-Output "Sync Online Application Instance to Active Directory"
Sync-CsOnlineApplicationInstance -ObjectId $objectIdA

if (![string]::IsNullOrEmpty($botApplicationIdB))
{
    start-process ("https://login.microsoftonline.com/" + $tenantIdB + "/adminconsent?client_id=" + $BotApplicationIdB)
    Sync-CsOnlineApplicationInstance -ObjectId $objectIdB
}

Write-Output "New Customer Registration Details" > $outputFilename
Write-Output ("Domain: " + $DomainName) >> $outputFilename
Write-Output ("Tenant Id: " + $tenantId) >> $outputFilename
Write-Output ("Admin Email: " + $AdminEmail) >> $outputFilename
Write-Output "" >> $outputFilename
Write-Output "Current Members" >> $outputFilename
Write-Output "" >> $outputFilename

$groupMembers = Get-AzureADGroupMember -ObjectId $recordingGroup.ObjectId
#Account	FirstName	LastName	EmailAddress	ExternalIdentifier	ExternalType	ServiceProviderId	ExternalGroup	Product	Language

$csvData = ""
$csvFilename = $DomainName + ".csv"
$csvData = "Account,FirstName,LastName,EmailAddress,ExternalIdentifier,ExternalType,ServiceProviderId,ExternalGroup,Product,Language`n" 

Foreach ($member in $groupMembers)
{
    $recordedUser = Get-CSOnlineUser -Identity $member.ObjectId
    Write-Output ("email: " + $recordedUser.WindowsEmailAddress) >> $outputFilename
    Write-Output ("Id: " + $recordedUser.ObjectId) >> $outputFilename
    Write-Output ("firstName: " + $recordedUser.FirstName) >> $outputFilename
    Write-Output ("lastName: " + $recordedUser.LastName) >> $outputFilename
    Write-Output ("mobileNumber: " + $recordedUser.MobilePhone) >> $outputFilename
    Write-Output "" >> $outputFilename

    $csvLine = "<account name>," + $recordedUser.FirstName + "," + 
                  $recordedUser.LastName + "," + $recordedUser.WindowsEmailAddress + "," + 
                  $recordedUser.ObjectId.ToString() + ",microsoft,microsoft," +
                  $recordedUser.TenantId.ToString() + ",<product>," +
                  $recordedUser.PreferredLanguage + "`n"

    $csvData += $csvLine
}

write-output $csvData | Out-File $csvFilename -Encoding ascii

