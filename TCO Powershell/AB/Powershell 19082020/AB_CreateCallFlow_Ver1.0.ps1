############################################
#Script to Create basic call flow          #
#Matches ABScript_Call_Flow_Diagram.vsdx   #
#Date: 22/03/2020                          #
#Written by Andrew Baird                   #
############################################

$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession -AllowClobber

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

#VoiceMail Stage
#Need exchange module installed
#Install-Module -Name ExchangeOnlineManagement
#Install-Module PowershellGet -Force
Connect-ExchangeOnline -Credential $Credential
$VmailDisplay = "Reception Voicemail5"
$VmailName = "Reception-Vmail5"
New-UnifiedGroup -DisplayName $VmailDisplay -Alias $VmailName
#Pause for 5 minute cause cloud lag
Write-Host 5 minute wait cause cloud lag sucks!
Start-Sleep -s 300
#Set Office 365 group as callable from AutoAttendant
$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription



#AutoAttendant for Voicemail
$domain = "M365x093990.onmicrosoft.com"
$aareceptionQName = "AA-ReceptionQ5"
$language = "en-AU"
$greetingTextAAQ = "Thank you for holding. Your call is very important to us. Unfortunately all our staff are on other calls please leave a voicemail with your name and contact number so one of our friendly staff can return your call."
$tz = "E. Australia Standard Time"
$MenuOptionAAQ = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $VmailcallableEntity
$greetingPromptAAQ = New-CsAutoAttendantPrompt -TextToSpeechPrompt $greetingTextAAQ
$menuAAQ = New-CsAutoAttendantMenu -Name "BusinessHoursmenuAAQ" -MenuOptions @($menuOptionAAQ)
$callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ -Greetings $greetingPromptAAQ
New-CsAutoAttendant -Name $aareceptionQName -Language $language -TimeZoneId $tz -DefaultCallFlow $callFlowAAQ
#Create AA-ReceptionQ Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aareceptionQName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aareceptionQName
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Start-Sleep 300
$aaappinstanceidAAQ = (Get-CsOnlineUser $aareceptionQName@$domain).ObjectId
$aaidAAQ = (Get-CsAutoAttendant -NameFilter $aareceptionQName).Identity
#Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceidAAQ -ConfigurationId $aaidAAQ -ConfigurationType AutoAttendant




# Call Queue Stage
$CQ1Name = "CQ-Reception5"
#Create Call Queue
New-CsCallQueue -Name $CQ1Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime 15 -UseDefaultMusicOnHold $true -TimeoutThreshold 15 -TimeoutAction Forward -TimeoutActionTarget $aaappinstanceidAAQ 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ1Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ1Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Start-Sleep -s 300
$CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain).ObjectId
$CQ1id = (Get-CsCallQueue -NameFilter $CQ1Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ1appinstanceid -ConfigurationId $CQ1id -ConfigurationType CallQueue


# AutoAttendant Stage
$aaName = "AA-Main5"
$language = "en-AU"
$greetingText = "Welcome to Concept Safety. Please hold the line while we connect you with one of the team."
$afterHoursText = "Thank you for calling Concept Safety. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."
$tz = "E. Australia Standard Time"
$tr1 = New-CsOnlineTimeRange -Start 08:00 -End 17:00

# After hours
$afterHoursSchedule = New-CsOnlineSchedule -Name "Business Hours" -WeeklyRecurrentSchedule -MondayHours @($tr1) -TuesdayHours @($tr1) -WednesdayHours @($tr1) -ThursdayHours @($tr1) -FridayHours @($tr1) -Complement
$afterHoursGreetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $afterHoursText
$afterHoursMenuOption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $VmailcallableEntity
$afterHoursMenu = New-CsAutoAttendantMenu -Name "AfterhoursMenu" -MenuOptions @($afterHoursMenuOption)
$afterHoursCallFlow = New-CsAutoAttendantCallFlow -Name "After Hours" -Menu $afterHoursMenu -Greetings @($afterHoursGreetingPrompt)
$afterHoursCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation -Type AfterHours -ScheduleId $afterHoursSchedule.Id -CallFlowId $afterHoursCallFlow.Id

# Business hours menu options
$operator = New-CsAutoAttendantCallableEntity -Identity $CQ1appinstanceid -Type applicationendpoint
$menuOption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $operator


# Business hours menu
$greetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $greetingText
$menu = New-CsAutoAttendantMenu -Name "BusinessHoursmenu" -MenuOptions @($menuOption)
$callFlow = New-CsAutoAttendantCallFlow -Name "Default" -Menu $menu -Greetings $greetingPrompt

# Auto attendant
New-CsAutoAttendant -Name $aaName -Language $language -CallFlows @($afterHoursCallFlow) -TimeZoneId $tz -Operator $operator -DefaultCallFlow $callFlow -CallHandlingAssociations @($afterHoursCallHandlingAssociation)

#Create AA-Main Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aaName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aaName
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Start-Sleep 300
$aaappinstanceid = (Get-CsOnlineUser $aaName@$domain).ObjectId
$aaid = (Get-CsAutoAttendant -NameFilter $aaName).Identity
#Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant




Remove-PSSession $sfboSession