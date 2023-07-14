$Credential = Get-Credential
Connect-MsolService -Credential $credential
Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession

Get-CsOnlineVoiceApplicationInstance -Identity aa-healthyminds-q@ncphn.org.au


Set-CsOnlineVoiceApplicationInstance -Identity aa-healthyminds-q@ncphn.org.au -TelephoneNumber "61266591822"

Get-CsOnlineVoiceUser -id mdaddo@ncphn.org.au

+61 2 6659 1825

Set-CsOnlineVoiceUser -id mdaddo@ncphn.org.au -TelephoneNumber +61266591825
