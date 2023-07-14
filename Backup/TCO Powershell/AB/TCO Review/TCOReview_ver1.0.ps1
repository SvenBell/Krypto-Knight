Connect-MicrosoftTeams

#Get-CsAutoAttendant
#Get-CsCallQueue
#Voicemail
#Holiday schedule
#Business hours
#Resource accounts

$targetids = Get-cscallqueue| select-object @{Label="TimeoutActionTarget";Expression={($_.TimeoutActionTarget.Id)}}
Get-CsOnlineUser -id 3a634b78-ffd7-4e5f-a550-db623789788f
Get-CsCallqueue -first 100 | select-object Name,Identity,ApplicationInstances,RoutingMethod,DistributionLists,Agents,AgentsInSyncWithDistributionLists,AllowOptOut,AgentsCapped,AgentAlertTime,OverflowThreshold,OverflowAction,@{Label="OverflowactionTarget";Expression={($_.OverflowactionTarget.Id)}}, @{Label="TimeoutActionTarget";Expression={($_.TimeoutActionTarget.Id)}},OverflowSharedVoicemailTextToSpeechPrompt,OverflowSharedVoicemailAudioFilePrompt,EnableOverflowSharedVoicemailTranscription,TimeoutThreshold,TimeoutAction,TimeoutSharedVoicemailTextToSpeechPrompt,TimeoutSharedVoicemailAudioFilePrompt,EnableTimeoutSharedVoicemailTranscription,WelcomeMusicFileName,UseDefaultMusicOnHold,MusicOnHoldFileName |export-csv -notypeinformation -append "C:\GitHub\PowerShell\TCO Powershell\AB\TCO Review\callqueuedata.csv"
$AAid = get-csautoattendant | select-object Name,identity,applicationInstances
Get-CsAutoAttendant -first 100 | select-object Name,Identity,applicationInstances,LanguageId,operator,TimeZoneId,voiceresponseenabled,schedules |export-csv -notypeinformation -append "C:\GitHub\PowerShell\TCO Powershell\AB\TCO Review\AutoAttendantdata.csv"
Get-CsAutoAttendantHolidays -id $AAid.Identity |select-object Year,Name,datetimeranges,callaction, Greetings |Export-csv -notypeinformation -append "C:\GitHub\PowerShell\TCO Powershell\AB\TCO Review\AutoAttendantHolidaysdata.csv"
Get-CsOnlineApplicationInstance | select-object UserPrincipalName,Displayname,PhoneNumber | Export-csv -notypeinformation -append "C:\GitHub\PowerShell\TCO Powershell\AB\TCO Review\ResourceAccountsdata.csv"
