Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession

#Create Call Group (Security Group)


#Create Call Queue with Resource account/ Australia location for licensing


#Create auto attendant, Resource account/ Australia location for licensing
#Business Hours, Aferhours annoucement, Greeting, Handover to call queue
Get-command "*csautoattendant*"
Get-command "*callqueue*"
Get-CsAutoAttendant

$GreetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt “Welcome to Banjo's IT Department. Please hold the line while we connect you with one of the team.”
#$automaticMenuOption = New-CsAutoAttendantMenuOption -Action redirect -DtmfResponse Automatic
#$Menu=New-CsAutoAttendantMenu -Name “Old menu” -MenuOptions @($automaticMenuOption)
$CallFlow = New-CsAutoAttendantCallFlow -Name “AA-IT Department” -Greetings @($GreetingPrompt) -Menu $Menu
New-CsOrganizationalAutoAttendant -Name “old way” -Language “en-US” -TimeZoneId “UTC” -DefaultCallFlow $CallFlow

New-CsAutoAttendant

New-CsAutoAttendantMenuOption -?

get-help New-CsAutoAttendantMenuOption -examples