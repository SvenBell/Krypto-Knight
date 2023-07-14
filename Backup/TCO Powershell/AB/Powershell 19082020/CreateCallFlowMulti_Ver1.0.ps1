################################################
#Script to Create basic call flow              #
#Matches Script_Call_Flow_DiagramMutli.vsdx  #
#Date: 26/03/2020                              #
#Written by Andrew Baird                       #
#Version: 1.0                                  #
################################################

$adminUPN = "admin@M365x675316.onmicrosoft.com"
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
$domain = "M365x675316.onmicrosoft.com"
$language = "en-AU"
$AgentalertCQ1 = "15"
$AgentalertCQ2 = "15"
$timezone = "E. Australia Standard Time"
$greetingText = "Welcome to XXXXXX. Please hold the line while we connect you with one of the team."
$afterHoursText = "Thank you for calling XXXXXX. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."
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

# Call Queue Marketing 2 Stage
$CQ2Name = "CQ-Marketing-2"
#Create Call Queue
New-CsCallQueue -Name $CQ2Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $aaappinstanceidAAQ 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ2Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ2Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue Marketing 2 Stage
Start-Sleep -s 300
$CQ2appinstanceid = (Get-CsOnlineUser $CQ2Name).ObjectId
$CQ2id = (Get-CsCallQueue -NameFilter $CQ2Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ2appinstanceid -ConfigurationId $CQ2id -ConfigurationType CallQueue


# Call Queue Marketing Stage
$CQ1Name = "CQ-Marketing"
#Create Call Queue
New-CsCallQueue -Name $CQ1Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ1 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ1 -TimeoutAction Forward -TimeoutActionTarget $CQ2appinstanceid 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ1Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ1Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue Marketing Stage
Start-Sleep -s 300
$CQ1appinstanceid = (Get-CsOnlineUser $CQ1Name).ObjectId
$CQ1id = (Get-CsCallQueue -NameFilter $CQ1Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ1appinstanceid -ConfigurationId $CQ1id -ConfigurationType CallQueue

# Call Queue Sales Stage
$CQ3Name = "CQ-Sales"
#Create Call Queue
New-CsCallQueue -Name $CQ3Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $aaappinstanceidAAQ 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ3Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ3Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue Sales Stage
Start-Sleep -s 300
$CQ3appinstanceid = (Get-CsOnlineUser $CQ3Name).ObjectId
$CQ3id = (Get-CsCallQueue -NameFilter $CQ3Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ3appinstanceid -ConfigurationId $CQ3id -ConfigurationType CallQueue

# Call Queue Finance-2 Stage
$CQ4Name = "CQ-Finance-2"
#Create Call Queue
New-CsCallQueue -Name $CQ4Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $aaappinstanceidAAQ 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ4Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ4Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue Finance-2 Stage
Start-Sleep -s 300
$CQ4appinstanceid = (Get-CsOnlineUser $CQ4Name).ObjectId
$CQ4id = (Get-CsCallQueue -NameFilter $CQ4Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ4appinstanceid -ConfigurationId $CQ4id -ConfigurationType CallQueue

# Call Queue Finance Stage
$CQ5Name = "CQ-Finance"
#Create Call Queue
New-CsCallQueue -Name $CQ5Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $CQ4appinstanceid 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ5Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ5Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue Finance Stage
Start-Sleep -s 300
$CQ5appinstanceid = (Get-CsOnlineUser $CQ5Name).ObjectId
$CQ5id = (Get-CsCallQueue -NameFilter $CQ5Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ5appinstanceid -ConfigurationId $CQ5id -ConfigurationType CallQueue

# Call Queue Infrastructure-2 Stage
$CQ6Name = "CQ-Infrastructure-2"
#Create Call Queue
New-CsCallQueue -Name $CQ6Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $aaappinstanceidAAQ 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ6Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ6Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue Infrastructure-2 Stage
Start-Sleep -s 300
$CQ6appinstanceid = (Get-CsOnlineUser $CQ6Name).ObjectId
$CQ6id = (Get-CsCallQueue -NameFilter $CQ6Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ6appinstanceid -ConfigurationId $CQ6id -ConfigurationType CallQueue

# Call Queue Infrastructure Stage
$CQ7Name = "CQ-Infrastructure"
#Create Call Queue
New-CsCallQueue -Name $CQ7Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $CQ6appinstanceid 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ7Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ7Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue Infrastructure Stage
Start-Sleep -s 300
$CQ7appinstanceid = (Get-CsOnlineUser $CQ7Name).ObjectId
$CQ7id = (Get-CsCallQueue -NameFilter $CQ7Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ7appinstanceid -ConfigurationId $CQ7id -ConfigurationType CallQueue

# Call Queue General Enquires-2 Stage
$CQ8Name = "CQ-GenEnq-2"
#Create Call Queue
New-CsCallQueue -Name $CQ8Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $aaappinstanceidAAQ 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ8Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ8Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue General Enquires-2 Stage
Start-Sleep -s 300
$CQ8appinstanceid = (Get-CsOnlineUser $CQ8Name).ObjectId
$CQ8id = (Get-CsCallQueue -NameFilter $CQ8Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ8appinstanceid -ConfigurationId $CQ8id -ConfigurationType CallQueue

# Call Queue General Enquires Stage
$CQ9Name = "CQ-GenEnq"
#Create Call Queue
New-CsCallQueue -Name $CQ9Name -RoutingMethod Attendant -AllowOptOut $true -AgentAlertTime $AgentalertCQ2 -UseDefaultMusicOnHold $true -TimeoutThreshold $AgentalertCQ2 -TimeoutAction Forward -TimeoutActionTarget $CQ8appinstanceid 
#Create Call Queue Resource Account
New-CsOnlineApplicationInstance -UserPrincipalName $CQ9Name@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQ9Name
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host Call Queue General Enquires Stage
Start-Sleep -s 300
$CQ9appinstanceid = (Get-CsOnlineUser $CQ9Name).ObjectId
$CQ9id = (Get-CsCallQueue -NameFilter $CQ9Name).Identity
#Associate Call Queue and CQ Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $CQ9appinstanceid -ConfigurationId $CQ9id -ConfigurationType CallQueue



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

#Create Resource accounts
$operator = New-CsAutoAttendantCallableEntity -Identity $CQ9appinstanceid -Type applicationendpoint
$CQ1call = New-CsAutoAttendantCallableEntity -Identity $CQ1appinstanceid -Type applicationendpoint
$CQ2call = New-CsAutoAttendantCallableEntity -Identity $CQ2appinstanceid -Type applicationendpoint
$CQ3call = New-CsAutoAttendantCallableEntity -Identity $CQ3appinstanceid -Type applicationendpoint
$CQ4call = New-CsAutoAttendantCallableEntity -Identity $CQ4appinstanceid -Type applicationendpoint
$CQ5call = New-CsAutoAttendantCallableEntity -Identity $CQ5appinstanceid -Type applicationendpoint
$CQ6call = New-CsAutoAttendantCallableEntity -Identity $CQ6appinstanceid -Type applicationendpoint
$CQ7call = New-CsAutoAttendantCallableEntity -Identity $CQ7appinstanceid -Type applicationendpoint


# Business hours menu options


$greetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt "Welcome to XXXXX Please hold to be connected to a friend staff member."
$menuOption1 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone1 -CallTarget $CQ1call
$menuOption2 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone2 -CallTarget $CQ3call
$menuOption3 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone3 -CallTarget $CQ5call
$menuOption4 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone4 -CallTarget $CQ7call
$menuOption5 = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Tone5 -CallTarget $operator
$menuPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt "For Marketing, press 1.   For Sales, press 2.   For Finance, press 3.   For Infrastructure, press 4.   For General Enquires, press 5."




# Business hours menu
$greetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $greetingText
$Menu = New-CsAutoAttendantMenu -Name "BusinessHoursmenu" -Prompts @($menuPrompt) -MenuOptions @($menuOption1,$menuOption2,$menuOption3,$menuOption4,$menuOption5) -EnableDialByName
$CallFlow = New-CsAutoAttendantCallFlow -Name "Default call flow" -Greetings @($greetingPrompt) -Menu $Menu

# Create Auto attendant
New-CsAutoAttendant -Name $aaName -Language $language -CallFlows @($afterHoursCallFlow) -TimeZoneId $timezone -Operator $operator -DefaultCallFlow $callFlow -CallHandlingAssociations @($afterHoursCallHandlingAssociation)

# Create AA-Main Resource account
New-CsOnlineApplicationInstance -UserPrincipalName $aaName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aaName
#Pause for 5 minute cause of cloud lag
Write-Host 5 minute wait
Write-Host AA-Main Stage
Start-Sleep 300
$aaappinstanceid = (Get-CsOnlineUser $aaName).ObjectId
$aaid = (Get-CsAutoAttendant -NameFilter $aaName).Identity

# Associate AutoAttendant and AA Resource account
New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant



Remove-PSSession $sfboSession