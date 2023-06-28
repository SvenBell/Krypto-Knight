
#Connect-MicrosoftTeams
Connect-ExchangeOnline


#Customise for each customer
########################################
$domain= "capilanohoney.onmicrosoft.com"
$Filename = "C:\Temp\BulkCallVoicemail-Create.csv"
$language = "en-AU"
$voiceprompt = "Thank you for holding. Your call is very important to us. Unfortunately our staff are on other calls please leave a voicemail with your name and contact number so one of our friendly staff can return your call."
########################################
#For testing
#    $VmailDisplay= "Retail Voicemail"
#    $VmailName = "Retail-Voicemail"
#    $CQName = "CQ-Retail"
#    $CQtimeout = "15"
########################################
#Load timer function
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


$users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {
    $VmailDisplay= $user.voicedisplayname
    $VmailName = $user.voicealias
    $CQName = $user.callqueue
    $CQtimeout = $user.timeout
	$voiceprompt = $user.vmprompt
	$AgentAlertTime = $user.agentalertime

#Create Microsoft365 Group for shared voicemail
New-UnifiedGroup -DisplayName $VmailDisplay -Alias $VmailName
#Get created group identity
$VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
#$? is a default powershell variable Contains the execution status of the last operation.
#It contains TRUE if the last operation succeeded and FALSE if it failed.
#Will check every 30 seconds till successful
if($? -ne 'False')
    {
    while($? -ne 'False')
    {
        Write-Host Voicemail Stage waiting
        Start-Sleep -s 30
        $VmailcallableEntityGroup = Find-CsGroup -SearchQuery "$VmailDisplay" -ExactMatchOnly $true -MailEnabledOnly $true | % { $_.Id }
    }
}
#Create callable identity for voicemail, sometimes there is a delay in the cloud so loop in use
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

$vmailid = $VmailcallableEntity | foreach { $_.id }

#Find existing Call queue by name
$CQ1id = (Get-CsCallQueue -Namefilter $CQName).identity
#Get call queue application Instance id
$CQ1appinstanceid =(Get-CsCallQueue -Namefilter $CQName).applicationInstances
#Set existing Call queue to forward to created shared voicemail
Set-CsCallQueue -id $CQ1id -AllowOptOut $true -AgentAlertTime $AgentAlertTime -UseDefaultMusicOnHold $true -OverflowThreshold 50 -TimeoutThreshold $CQtimeout -ConferenceMode $true -LanguageId $language -OverflowAction SharedVoicemail -OverflowSharedVoicemailTextToSpeechPrompt $voiceprompt -OverflowActionTarget $vmailid -EnableOverflowSharedVoicemailTranscription $true -TimeoutAction SharedVoicemail -EnableTimeoutSharedVoicemailTranscription $true -TimeoutSharedVoicemailTextToSpeechPrompt $voiceprompt -TimeoutActionTarget $vmailid

Write-host "Call Queue" $CQName "now overflowing and timing out to" $VmailDisplay

}


# Disconnect-MicrosoftTeams