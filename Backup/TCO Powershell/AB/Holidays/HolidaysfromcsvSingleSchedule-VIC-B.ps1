
#$Credential = Get-Credential
#install-module msonline
Connect-MicrosoftTeams
#Connect-MsolService

#Starting with Queens Birthday
$newyears = New-CsOnlineDateTimeRange -Start "14/06/2021 0:00" -End "14/06/2021 23:45"
$schedule = New-CsOnlineSchedule -name "VIC Holidays 2021-B" -Fixedschedule -DateTimeRanges $newyears


$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\Holidays\Holidays2021-VIC-formatted-B.csv"


    $dates = Import-Csv $FileName
    foreach ($date in $dates)
    {
        $name = $date.name
        $start= $date.startdate
        $end= $date.enddate
        $schedule.Fixedschedule.DateTimeRanges += New-CsOnlineDateTimeRange -Start "$start" -End "$end"
        Set-csonlineSchedule -Instance $schedule
        

    }

GET-PSSession | Remove-PSSession