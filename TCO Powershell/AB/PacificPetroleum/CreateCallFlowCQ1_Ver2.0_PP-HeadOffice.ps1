############################################
#Script to Create basic call flow          #
#Matches Script_Call_Flow_DiagramCQ1.vsdx   #
#Date: 06/11/2020                          #
#Written by Andrew Baird                   #
#Version: 2.0                              #
############################################

Connect-MicrosoftTeams
Connect-MsolService

function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}

#Variables that will change for each customer
$domain = "pacificpetroleum.onmicrosoft.com"
$language = "en-AU"
$AgentalertCQ1 = "15"
$timezone = "E. Australia Standard Time"
$greetingText = "Welcome to Pacific Petroleum. Please hold the line while we connect you with one of the team"
#$afterHoursText = "Thank you for calling River CIty Solutions. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."
$greetingTextAAQ = "Thank you for holding. Your call is very important to us. Unfortunately all our staff are on other calls please leave a voicemail with your name and contact number so one of our friendly staff can return your call."
#$holidaystext = "Thank you for calling River CIty Solutions. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."
$content = Get-Content "C:\Temp\PP\OOH000_Pacific_Petroleum_Pty_Ltd_8k16.wav" -Encoding byte -ReadCount 0
$afterhoursaudioFile = Import-CsOnlineAudioFile -ApplicationId "OrgAutoAttendant" -FileName "OOH000_Pacific_Petroleum_Pty_Ltd_8k16.wav" -Content $content
$afterHoursGreetingPrompt = New-CsAutoAttendantPrompt -AudioFilePrompt $afterhoursaudioFile

#VoiceMail Stage
#Need exchange module installed
#Install-Module -Name ExchangeOnlineManagement
#Install-Module PowershellGet -Force
Connect-ExchangeOnline
$VmailDisplay = "VM-Rocklea"
$VmailName = "VM-Rocklea"
New-UnifiedGroup -DisplayName $VmailDisplay -Alias $VmailName
#Loop every 30 seconds till new Office365 group found in Azure AD
$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
if($? -ne 'False')
{
    while($? -ne 'false')
    {
        Write-Host Voicemail Stage waiting
        Start-Sleep -s 30
        $VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
    }
}
$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription
if($? -ne 'False')
{
    while($? -ne 'False')
    {
        Write-Host Voicemail Stage waiting
        Start-Sleep -s 30
        $VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription

    }
}
Write-Host Voicemail 2nd Stage
#Set Office 365 group as callable from AutoAttendant
#$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
#$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription
$vmailid = $VmailcallableEntity | foreach { $_.id }

# Call Queue 2 Stage
$CQ2Name = "CQ-CustomerService"
#Create Call Queue
New-CsCallQueue -Name $CQ2Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ1 -UseDefaultMusicOnHold $true -OverflowThreshold 50 -TimeoutThreshold $AgentalertCQ1 -ConferenceMode $true -LanguageId $language -timeoutsharedvoicemailtexttospeechprompt $greetingTextAAQ -TimeoutAction SharedVoicemail -TimeoutActionTarget $vmailid
New-CsOnlineApplicationInstance -UserPrincipalName $CQ2Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ2Name
#Loop every 30 seconds till new Call Queue Resource account found in Azure AD
$CQ2appinstanceid = (Get-CsOnlineUser $CQ2Name@$domain).ObjectId
if($? -ne 'False')
{
    while($? -ne 'false')
    {
        Write-Host Call Queue 2 Stage waiting
        Start-Sleep -s 30
        $CQ2appinstanceid = (Get-CsOnlineUser $CQ2Name@$domain).ObjectId
    }
}
$CQ2id = (Get-CsCallQueue -NameFilter $CQ2Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ2appinstanceid -ConfigurationId $CQ2id -ConfigurationType CallQueue

# Call Queue 1 Stage
$CQ1Name = "CQ-Reception"
#Create Call Queue
New-CsCallQueue -Name $CQ1Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ1 -UseDefaultMusicOnHold $true -OverflowThreshold 50 -TimeoutThreshold $AgentalertCQ1 -ConferenceMode $true -LanguageId $language -OverflowAction Forward -OverflowActionTarget $CQ2appinstanceid -TimeoutAction Forward -TimeoutActionTarget $CQ2appinstanceid
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ1Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ1Name
#Loop every 30 seconds till new Call Queue Resource account found in Azure AD
$CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain).ObjectId
if($? -ne 'False')
{
    while($? -ne 'false')
    {
        Write-Host Call Queue 1 Stage waiting
        Start-Sleep -s 30
        $CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain).ObjectId
    }
}
$CQ1id = (Get-CsCallQueue -NameFilter $CQ1Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ1appinstanceid -ConfigurationId $CQ1id -ConfigurationType CallQueue


# AutoAttendant Main Stage
$aaName = "AA-Rocklea"
$tr1 = New-CsOnlineTimeRange -Start 08:00 -End 17:15
$tr2 = New-CsOnlineTimeRange -Start 08:00 -End 16:30 
# After hours
$afterHoursSchedule = New-CsOnlineSchedule -Name "Business Hours" -WeeklyRecurrentSchedule -MondayHours @($tr1) -TuesdayHours @($tr1) -WednesdayHours @($tr1) -ThursdayHours @($tr1) -FridayHours @($tr2) -Complement
#$afterHoursGreetingPrompt = New-CsAutoAttendantPrompt -AudioFilePrompt $audioFilePrompt
$afterHoursMenuOption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $VmailcallableEntity
$afterHoursMenu = New-CsAutoAttendantMenu -Name "AfterhoursMenu" -MenuOptions @($afterHoursMenuOption)
#$HolidayMenu = New-CsAutoAttendantMenu -Name "HolidayMenu" -MenuOptions @($afterHoursMenuOption)
$afterHoursCallFlow = New-CsAutoAttendantCallFlow -Name "After Hours" -Menu $afterHoursMenu -Greetings @($afterHoursGreetingPrompt)
$afterHoursCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation -Type AfterHours -ScheduleId $afterHoursSchedule.Id -CallFlowId $afterHoursCallFlow.Id


# Business hours menu options
$operator = New-CsAutoAttendantCallableEntity -Identity $CQ1appinstanceid -Type applicationendpoint
$menuOption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $operator

# Business hours menu
$greetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $greetingText
$menu = New-CsAutoAttendantMenu -Name "BusinessHoursmenu" -MenuOptions @($menuOption)
$callFlow = New-CsAutoAttendantCallFlow -Name "Default" -Menu $menu -Greetings $greetingPrompt

# Create Auto attendant
New-CsAutoAttendant -Name $aaName -Language $language -CallFlows @($afterHoursCallFlow) -TimeZoneId $timezone -Operator $operator -DefaultCallFlow $callFlow -CallHandlingAssociations @($afterHoursCallHandlingAssociation)

# Create AA-Main Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aaName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aaName

$aaappinstanceid = (Get-CsOnlineUser $aaName@$domain).ObjectId
if($? -ne 'False')
{
    while($? -ne 'false')
    {
        Write-Host AutoAttendant Stage waiting
        Start-Sleep -s 30
        $aaappinstanceid = (Get-CsOnlineUser $aaName@$domain).ObjectId
    }
}
$aaid = (Get-CsAutoAttendant -NameFilter $aaName).Identity

# Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant

#Holidays
$autoattendant = get-csautoattendant | where-object Name -eq "AA-Rocklea"
$holidaysschedule = get-csonlineschedule | where-object Name -eq "QLD Holidays 2021"
#$holidaysGreetingprompt = New-CsAutoAttendantPrompt -AudioFilePrompt $audioFilePrompt
$holidaysmenuoption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $VmailcallableEntity
$holidaysmenu = New-CsAutoAttendantMenu -Name "HolidaysMenu" -MenuOptions @($holidaysMenuOption)
$holidayscallflow = New-CsAutoAttendantCallFlow -Name "Holidays" -Menu $holidaysMenu -Greetings @($afterHoursGreetingPrompt)
$holidaysCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation -Type holiday -ScheduleId $holidaysschedule.Id -CallFlowId $holidayscallflow.Id

$autoAttendant.CallFlows += @($holidaysCallFlow)
$autoAttendant.CallHandlingAssociations += @($holidaysCallHandlingAssociation)

set-csautoattendant -instance $autoattendant 

Disconnect-MicrosoftTeams