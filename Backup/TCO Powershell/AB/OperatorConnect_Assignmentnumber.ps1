
Connect-MicrosoftTeams
Update-module MicrosoftTeams

Get-InstalledModule 

$upn= "john.smith@entag-demo.com"
$number= "61754398603"

Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail

write-host $name.DisplayName $upn "assigning" $number -foregroundcolor Green 

Set-CsPhoneNumberAssignment -id $upn -phonenumber $number -phonenumbertype OperatorConnect

Disconnect-MicrosoftTeams