############################################
#Script to Create basic call flow          #
#Matches Script_Call_Flow_DiagramCQ1.vsdx   #
#Date: 06/11/2020                          #
#Written by Andrew Baird                   #
#Version: 2.0                              #
############################################

Connect-MicrosoftTeams
Connect-MsolService
Connect-ExchangeOnline

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
$domain = "tshopbiz.onmicrosoft.com"
$language = "en-AU"
$AgentalertCQ1 = "60"
$timezone = "E. Australia Standard Time"

#$greetingText = "Welcome to Pacific Petroleum. Please hold the line while we connect you with one of the team"
#$afterHoursText = "Thank you for calling River CIty Solutions. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."
#$greetingTextAAQ = "Thank you for holding. Your call is very important to us. Unfortunately all our staff are on other calls please leave a voicemail with your name and contact number so one of our friendly staff can return your call."
#$holidaystext = "Thank you for calling River CIty Solutions. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."
#$content = Get-Content "C:\Temp\PP\OOH000_Pacific_Petroleum_Pty_Ltd_8k16.wav" -Encoding byte -ReadCount 0
#$afterhoursaudioFile = Import-CsOnlineAudioFile -ApplicationId "OrgAutoAttendant" -FileName "OOH000_Pacific_Petroleum_Pty_Ltd_8k16.wav" -Content $content
#$afterHoursGreetingPrompt = New-CsAutoAttendantPrompt -AudioFilePrompt $afterhoursaudioFile
$VmailDisplay = "FleetMobilitySupport-Voicemail"
$VmailName = "FleetMobilitySupport-Voicemail"
$CQ1Name = "CQ-FleetMobilitySupport"
$aaHoldName = "AA-FleetMobilitySupportHold"
$aaName = "AA-FleetMobilitySupport"

# AutoAttendant Main Stage

$greetingcontent = Get-Content "C:\Users\AndrewBaird\TShopBiz & Entag Group\ENTAG Connect - Documents\Customers\ENTAG Group\TCO\Entag Office move\Brisbane\OneDrive_1_12-08-2021_Refined\Mobility-Welcome-Generic.wav" -Encoding byte -ReadCount 0
$greetingaudioFile = Import-CsOnlineAudioFile -ApplicationId "OrgAutoAttendant" -FileName "Mobility-Welcome-Generic.wav" -Content $greetingcontent
$Welcomegreetingprompt = New-CsAutoAttendantPrompt -AudioFilePrompt $greetingaudioFile


# AutoAttendant Queue hold Stage

$holdgreetingcontent = Get-Content "C:\Users\AndrewBaird\TShopBiz & Entag Group\ENTAG Connect - Documents\Customers\ENTAG Group\TCO\Entag Office move\Brisbane\OneDrive_1_12-08-2021_Refined\Mobility-SupportHold.wav" -Encoding byte -ReadCount 0
$holdgreetingaudioFile = Import-CsOnlineAudioFile -ApplicationId "OrgAutoAttendant" -FileName "Mobility-SupportHold.wav" -Content $holdgreetingcontent
$holdgreetingprompt = New-CsAutoAttendantPrompt -AudioFilePrompt $holdgreetingaudioFile


$tr1 = New-CsOnlineTimeRange -Start 08:00 -End 20:00


#VoiceMail Stage
#Need exchange module installed
#Install-Module -Name ExchangeOnlineManagement
#Install-Module PowershellGet -Force
$VmailcallableEntity = $null
$VmailcallableEntityGroup = $null
New-UnifiedGroup -DisplayName $VmailDisplay -Alias $VmailName
#Loop every 30 seconds till new Office365 group found in Azure AD
$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
if(!$VmailcallableEntityGroup)
{
    while(!$VmailcallableEntityGroup)
    {
        Write-Host Voicemail Callable Group Stage waiting
        Start-Sleep -s 30
        $VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }

    }
}
$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription
if(!$VmailcallableEntity)
{
    while(!$VmailcallableEntity)
    {
        Write-Host Voicemail Callable Entity Stage waiting2
        Start-Sleep -s 30
        $VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription

    }
}
Write-Host Voicemail 2nd Stage
#Set Office 365 group as callable from AutoAttendant
#$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
#$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription
$vmailid = $VmailcallableEntity | foreach { $_.id }

# Call Queue 1 Stage

#Create Call Queue
New-CsCallQueue -Name $CQ1Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ1 -UseDefaultMusicOnHold $true -OverflowThreshold 50 -TimeoutThreshold $AgentalertCQ1 -ConferenceMode $true -LanguageId $language -OverflowAction DisconnectWithBusy -TimeoutAction Disconnect
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ1Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ1Name
#Loop every 30 seconds till new Call Queue Resource account found in Azure AD
$CQ1appinstanceid = $null
$CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain).ObjectId
if(!$CQ1appinstanceid)
{
    while(!$CQ1appinstanceid)
    {
        Write-Host Call Queue 1 Stage waiting
        Start-Sleep -s 30
        $CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain).ObjectId
    }
}
$CQ1id = (Get-CsCallQueue -NameFilter $CQ1Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ1appinstanceid -ConfigurationId $CQ1id -ConfigurationType CallQueue




#Menu
$aaHoldNamemenu = $aaHoldName+"menu"
$CQ1callable = New-CsAutoAttendantCallableEntity -Identity $CQ1appinstanceid -Type applicationendpoint
$holdmenuOption1 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone1 -CallTarget $CQ1callable
$holdmenuOption2 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone2 -CallTarget $VmailcallableEntity
$holdmenu = New-CsAutoAttendantMenu -Name $aaHoldNamemenu -Prompts @($holdgreetingprompt) -EnableDialByName -MenuOptions @($holdmenuOption1,$holdmenuOption2)
$holdcallFlow = New-CsAutoAttendantCallFlow -Name "Default" -Menu $holdmenu -Greetings $holdgreetingPrompt

# Create Hold Auto attendant
New-CsAutoAttendant -Name $aaHoldName -LanguageId $language -TimeZoneId $timezone -DefaultCallFlow $holdcallFlow

# Create AA-Main Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aaholdName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aaholdName
$aaholdappinstanceid = $null
$aaholdappinstanceid = (Get-CsOnlineUser $aaholdName@$domain).ObjectId
if(!$aaholdappinstanceid)
{
    while(!$aaholdappinstanceid)
    {
        Write-Host AutoAttendant Stage waiting
        Start-Sleep -s 30
        $aaholdappinstanceid = (Get-CsOnlineUser $aaholdName@$domain).ObjectId
    }
}
$aaholdid = (Get-CsAutoAttendant -NameFilter $aaholdName).Identity

# Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaholdappinstanceid -ConfigurationId $aaholdid -ConfigurationType AutoAttendant

#Set Call Queue target to AAHold

Set-CsCallQueue -identity $CQ1id -timeoutaction Forward -timeoutactiontarget $aaholdappinstanceid



# AutoAttendant Main Stage


#$tr2 = New-CsOnlineTimeRange -Start 08:00 -End 16:30 
# After hours
$afterHoursSchedule = New-CsOnlineSchedule -Name "Business Hours" -WeeklyRecurrentSchedule -MondayHours @($tr1) -TuesdayHours @($tr1) -WednesdayHours @($tr1) -ThursdayHours @($tr1) -FridayHours @($tr2) -Complement
#$afterHoursGreetingPrompt = New-CsAutoAttendantPrompt -AudioFilePrompt $Welcomegreetingprompt
$afterHoursMenuOption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $VmailcallableEntity
$afterHoursMenu = New-CsAutoAttendantMenu -Name "AfterhoursMenu" -MenuOptions @($afterHoursMenuOption)
#$HolidayMenu = New-CsAutoAttendantMenu -Name "HolidayMenu" -MenuOptions @($afterHoursMenuOption)
$afterHoursCallFlow = New-CsAutoAttendantCallFlow -Name "After Hours" -Menu $afterHoursMenu
$afterHoursCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation -Type AfterHours -ScheduleId $afterHoursSchedule.Id -CallFlowId $afterHoursCallFlow.Id


# Business hours menu options
#$operator = New-CsAutoAttendantCallableEntity -Identity $CQ1appinstanceid -Type applicationendpoint
$menuOption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $CQ1callable

# Business hours menu
#$greetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $greetingText
$menu = New-CsAutoAttendantMenu -Name "BusinessHoursmenu" -MenuOptions @($menuOption)
$callFlow = New-CsAutoAttendantCallFlow -Name "Default" -Menu $menu -Greetings $Welcomegreetingprompt

# Create Auto attendant
New-CsAutoAttendant -Name $aaName -Language $language -TimeZoneId $timezone -Operator $operator -DefaultCallFlow $callFlow

# Create AA-Main Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aaName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aaName
$aaappinstanceid = $null
$aaappinstanceid = (Get-CsOnlineUser $aaName@$domain).ObjectId
if(!$aaappinstanceid)
{
    while(!$aaappinstanceid)
    {
        Write-Host AutoAttendant Stage waiting
        Start-Sleep -s 30
        $aaappinstanceid = (Get-CsOnlineUser $aaName@$domain).ObjectId
    }
}
$aaid = (Get-CsAutoAttendant -First 1 -NameFilter $aaName).Identity

# Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant


Disconnect-MicrosoftTeams