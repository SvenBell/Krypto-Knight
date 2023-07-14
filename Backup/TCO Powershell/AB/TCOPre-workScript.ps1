#TCO Pre-Work Script

Connect-MicrosoftTeams
Get-CsTeamsUpgradePolicy -Identity Global

#Enable Global Call Park Policy
Set-CsTeamsCallParkPolicy -identity 'Global' -AllowCallPark $true

#Found this callhold commands but there is no Microsoft documentation on it?
#Get-CsTeamsCallHoldPolicy
#Set-CsTeamsCallHoldPolicy

#Enable Teams Meeting QoS
Set-CsTeamsMeetingConfiguration -EnableQoS $true

#Export List of current phone numbers in Tenancy
Get-csOnlineTelephonenumber | Select id,CityCode,inventoryType,UserId,ActivationState | Export-CSV "C:\temp\Phonenumberexport.csv" -NoTypeInformation

