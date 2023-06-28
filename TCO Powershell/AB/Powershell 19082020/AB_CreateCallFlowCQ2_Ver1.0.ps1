############################################
#Script to Create basic call flow          #
#Matches ABScript_Call_Flow_DiagramCQ2.vsdx#
#Date: 22/03/2020                          #
#Written by Andrew Baird                   #
#Version: 1.0                              #
############################################

$adminUPN = andrew.baird@locatrix.com
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

#Variables that will change for each customer
$domain = "locatrix.com"
$language = "en-AU"
$AgentalertCQ1 = "15"
$AgentalertCQ2 = "15"
$timezone = "E. Australia Standard Time"
$greetingText = "Welcome to Locatrix. Please hold the line while we connect you with one of the team."
$afterHoursText = "Thank you for calling Locatrix. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."
$greetingTextAAQ = "Thank you for holding. Your call is very important to us. Unfortunately all our staff are on other calls please leave a voicemail with your name and contact number so one of our friendly staff can return your call."


#VoiceMail Stage
#Need exchange module installed
#Install-Module -Name ExchangeOnlineManagement
#Install-Module PowershellGet -Force
Connect-ExchangeOnline -UserPrincipalName $adminUPN
$VmailDisplay = "Reception Voicemail"
$VmailName = "Reception-Vmail"
New-UnifiedGroup -DisplayName $VmailDisplay -Alias $VmailName
#Pause for 5 minute cause cloud lag
Write-Host 5 minute wait cause cloud lag sucks!
Write-Host Voicemail Stage
Start-Sleep -s 300
#Set Office 365 group as callable from AutoAttendant
$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription



#AutoAttendant ReceptionQ for Voicemail
$aareceptionQName = "AA-ReceptionQ"
$MenuOptionAAQ = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $VmailcallableEntity
$greetingPromptAAQ = New-CsAutoAttendantPrompt -TextToSpeechPrompt $greetingTextAAQ
$menuAAQ = New-CsAutoAttendantMenu -Name "BusinessHoursmenuAAQ" -MenuOptions @($menuOptionAAQ)
$callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ -Greetings $greetingPromptAAQ
New-CsAutoAttendant -Name $aareceptionQName -Language $language -TimeZoneId $timezone -DefaultCallFlow $callFlowAAQ
#Create AA-ReceptionQ Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aareceptionQName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aareceptionQName
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host ReceptionQ Stage
Start-Sleep 300
$aaappinstanceidAAQ = (Get-CsOnlineUser $aareceptionQName@$domain).ObjectId
$aaidAAQ = (Get-CsAutoAttendant -NameFilter $aareceptionQName).Identity
#Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceidAAQ -ConfigurationId $aaidAAQ -ConfigurationType AutoAttendant

# Call Queue 2 Stage
$CQ2Name = "CQ-Overflow"
#Create Call Queue
New-CsCallQueue -Name $CQ2Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $aaappinstanceidAAQ 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ2Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ2Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue 2 Stage
Start-Sleep -s 300
$CQ2appinstanceid = (Get-CsOnlineUser $CQ2Name@$domain).ObjectId
$CQ2id = (Get-CsCallQueue -NameFilter $CQ2Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ2appinstanceid -ConfigurationId $CQ2id -ConfigurationType CallQueue


# Call Queue 1 Stage
$CQ1Name = "CQ-Reception"
#Create Call Queue
New-CsCallQueue -Name $CQ1Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ1 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ1 -TimeoutAction Forward -TimeoutActionTarget $CQ2appinstanceid
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ1Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ1Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue 1 Stage
Start-Sleep -s 300
$CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain).ObjectId
$CQ1id = (Get-CsCallQueue -NameFilter $CQ1Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ1appinstanceid -ConfigurationId $CQ1id -ConfigurationType CallQueue


# AutoAttendant Main Stage
$aaName = "AA-Main"
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

# Create Auto attendant
New-CsAutoAttendant -Name $aaName -Language $language -CallFlows @($afterHoursCallFlow) -TimeZoneId $timezone -Operator $operator -DefaultCallFlow $callFlow -CallHandlingAssociations @($afterHoursCallHandlingAssociation)

# Create AA-Main Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aaName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aaName
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host AA-Main Stage
Start-Sleep 300
$aaappinstanceid = (Get-CsOnlineUser $aaName@$domain).ObjectId
$aaid = (Get-CsAutoAttendant -NameFilter $aaName).Identity

# Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant



Remove-PSSession $sfboSession