Connect-MicrosoftTeams



Set-CsTeamsCallingPolicy -id "global" -BusyOnBusyEnabledType "unanswered"

Get-CsTeamsCallingPolicy -id "global"