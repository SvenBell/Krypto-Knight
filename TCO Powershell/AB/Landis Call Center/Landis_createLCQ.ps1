#Landis Call Center Commands

#LCQ-AB-Test
install-module MicrosoftTeams -Verbose
import-module MicrosoftTeams
Connect-MicrosoftTeams

$Instance = Set-CsOnlineApplicationInstance -ApplicationId "341e195c-b261-4b05-8ba5-dd4a89b1f3e7" -Identity "LCQ-AB-Test@tshopbiz.onmicrosoft.com"

Sync-CsOnlineApplicationInstance -ObjectID $Instance.ObjectID

$Instance.ObjectID

Grant-CsTeamsComplianceRecordingPolicy -Identity "aimee.mcmahon@entag.com.au" -PolicyName LandisContactCenterRecordingPolicy