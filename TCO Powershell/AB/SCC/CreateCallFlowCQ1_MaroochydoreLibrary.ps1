############################################
#Script to Create basic call flow-Kawana-Library #
#Matches Script_Call_Flow_DiagramCQ1.vsdx  #
#Date: 06/11/2020                          #
#Modified: 11/10/2021                      #
#Written by Andrew Baird                   #
#Version: 2.0                              #
############################################


Connect-MicrosoftTeams
#Install-Module MicrosoftTeams -Force
#Import-Module MicrosoftTeams
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
$domain = "sunshinecoastcouncil.onmicrosoft.com"
$language = "en-AU"
$AgentalertCQ1 = "15"
$TimeoutCQ1 = "60"
$timezone = "E. Australia Standard Time"
$greetingText = "Welcome to Maroochydore Library. Please hold the line while we connect you with one of the team."
$afterHoursText = "Thank you for calling, our office hours are 9:00 to 5:00 Monday to Friday excluding public holidays please leave a message and we will get back to you"
$greetingTextAAQ = "Thank you for holding. Your call is very important to us. Unfortunately our staff are on other calls please leave a voicemail with your name and contact number so one of our friendly staff can return your call."
$holidaygreetingtext = "Thank you for calling, our office hours are 9:00 to 5:00 Monday to Friday excluding public holidays please leave a message and we will get back to you "
#----
$Sitename = "MaroochyLibrary"
$VmailDisplay = "VM-"+$sitename
$VmailName = "VM-"+$sitename

#----
$CQ1Name = "CQ-"+$sitename
#Attendant | Serial | RoundRobin | LongestIdle
$routingmethod = "Serial"
#----
$aaName = "AA-"+$sitename
$tr1 = $null
$tr1 = New-CsOnlineTimeRange -Start 09:00 -End 17:00
$tr2 = $null
#$tr2 = New-CsOnlineTimeRange -Start 10:00 -End 14:00


#VoiceMail Stage
#Need exchange module installed
#Install-Module -Name ExchangeOnlineManagement
#Install-Module PowershellGet -Force
##Connect-ExchangeOnline -Credential $Credential

##New-UnifiedGroup -DisplayName $VmailDisplay -Alias $VmailName
#Pause for 5 minute cause cloud lag
#Write-Host 5 minute wait cause cloud lag sucks!
#Write-Host Voicemail Stage
$VmailcallableEntityGroup = $null
$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id } -ErrorAction SilentlyContinue;
if(!$VmailcallableEntityGroup)
{
    while(!$VmailcallableEntityGroup)
    {
        Write-Host Voicemail Stage waiting
        Start-Sleep -s 30
        $VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
    }
}
$VmailcallableEntity = $null
$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription
if(!$VmailcallableEntity)
{
    while(!$VmailcallableEntity)
    {
        Write-Host Voicemail Stage waiting
        Start-Sleep -s 30
        $VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription

    }
}
#Set Office 365 group as callable from AutoAttendant
$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
$VmailcallableEntity = New-CsAutoAttendantCallableEntity -Identity $VmailcallableEntityGroup -Type SharedVoicemail -EnableTranscription



#AutoAttendant ReceptionQ for Voicemail
#$aareceptionQName = "AA-ReceptionQ6"
#$MenuOptionAAQ = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $VmailcallableEntity
#$greetingPromptAAQ = New-CsAutoAttendantPrompt -TextToSpeechPrompt $greetingTextAAQ
#$menuAAQ = New-CsAutoAttendantMenu -Name "BusinessHoursmenuAAQ" -MenuOptions @($menuOptionAAQ)
#$callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ -Greetings $greetingPromptAAQ
#New-CsAutoAttendant -Name $aareceptionQName -Language $language -TimeZoneId $timezone -DefaultCallFlow $callFlowAAQ
#Create AA-ReceptionQ Resource account
#New-CsOnlineApplicationInstance -UserPrincipalName $aareceptionQName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aareceptionQName
#Pause for 5 minute cause of cloud lag
#Write-Host 5 minute wait
#Write-Host AA ReceptionQ Stage
#Start-Sleep 300
#$aaappinstanceidAAQ = (Get-CsOnlineUser $aareceptionQName@$domain).ObjectId
#$aaidAAQ = (Get-CsAutoAttendant -NameFilter $aareceptionQName).Identity
#Associate AutoAttendant and AA Resource account
#New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceidAAQ -ConfigurationId $aaidAAQ -ConfigurationType AutoAttendant




# Call Queue 1 Stage
$AAredirect1 = "AA-LibraryRedirect"
$AAredirect = Get-CsOnlineApplicationInstance -identity $AAredirect1@$domain


#Create Call Queue
New-CsCallQueue -Name $CQ1Name -RoutingMethod $routingmethod -AllowOptOut $true -AgentAlertTime $AgentalertCQ1 -LanguageId $language -UseDefaultMusicOnHold $true -ConferenceMode $true -TimeoutThreshold $TimeoutCQ1 -TimeoutAction Forward -TimeoutActionTarget $AAredirect.ObjectId
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ1Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ1Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-host Call Queue 1
#Start-Sleep -s 300
$CQ1appinstanceid = $null
$CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain -ErrorAction SilentlyContinue).ObjectId 
if(!$CQ1appinstanceid)
{
    while(!$CQ1appinstanceid)
    {
        Write-Host Call Queue 1 Stage waiting
        Start-Sleep -s 30
        $CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name@$domain -ErrorAction SilentlyContinue).ObjectId
    }
}
$CQ1id = $null
$CQ1id = (Get-CsCallQueue -NameFilter $CQ1Name -ErrorAction SilentlyContinue).Identity
if(!$CQ1id)
{
    while(!$CQ1id)
    {
        Write-Host Call Queue 1 Stage waiting
        Start-Sleep -s 30
        $CQ1id = (Get-CsCallQueue -NameFilter $CQ1Name -ErrorAction SilentlyContinue).Identity
    }
}
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ1appinstanceid -ConfigurationId $CQ1id -ConfigurationType CallQueue


# AutoAttendant Main Stage


# After hours
$afterHoursSchedule = New-CsOnlineSchedule -Name "Business Hours" -WeeklyRecurrentSchedule -MondayHours @($tr1) -TuesdayHours @($tr1) -WednesdayHours @($tr1) -ThursdayHours @($tr1) -FridayHours @($tr1) -Complement
$afterHoursGreetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $afterHoursText
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
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host AA-Main Stage
#Start-Sleep 300
$aaappinstanceid = $null
$aaappinstanceid = (Get-CsOnlineUser $aaName@$domain -ErrorAction SilentlyContinue).ObjectId 
if(!$aaappinstanceid)
{
    while(!$aaappinstanceid)
    {
        Write-Host Call Queue 1 Stage waiting
        Start-Sleep -s 30
        $aaappinstanceid = (Get-CsOnlineUser $aaName@$domain -ErrorAction SilentlyContinue).ObjectId
    }
}
$aaid = $null
$aaid = (Get-CsAutoAttendant -NameFilter $aaName -ErrorAction SilentlyContinue).Identity
if(!$aaid)
{
    while(!$aaid)
    {
        Write-Host Call Queue 1 Stage waiting
        Start-Sleep -s 30
        $aaid = (Get-CsAutoAttendant -NameFilter $aaName -ErrorAction SilentlyContinue).Identity
    }
}
# Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant



Disconnect-MicrosoftTeams