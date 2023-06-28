#Basic Script to enable unanswered of busy to the global calling policy
#14/06/2021 Andrew Baird
#Reach out if there are any issues.
Connect-MicrosoftTeams
#Change global to name of custom policy if needed
Set-CsTeamsCallingPolicy -id "Global" -BusyOnBusyEnabledType "unanswered"

Disconnect-MicrosoftTeams