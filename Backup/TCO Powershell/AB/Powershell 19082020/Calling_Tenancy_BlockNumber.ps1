$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession

#Get-CsInboundBlockedNumberPattern

#New-CsInboundBlockedNumberPattern -Description "Test AB block" -Name "ABBlock" -pattern "^\+61411198154"

#Set-CsInboundBlockedNumberPattern -Identity "ABBlock" -Pattern "^\+61411198144"

#Remove-CsInboundBlockedNumberPattern -id "ABBlock"


