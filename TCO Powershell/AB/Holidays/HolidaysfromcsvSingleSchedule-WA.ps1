
#$Credential = Get-Credential
#install-module msonline
Connect-MicrosoftTeams
#Connect-MsolService

#Starting with New Years
$newyears = New-CsOnlineDateTimeRange -Start "1/01/2021 0:00" -End "2/01/2021 0:00"
$schedule = New-CsOnlineSchedule -name "WA Public Holidays 2021" -Fixedschedule -DateTimeRanges $newyears


$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\Holidays\Holidays2021-WA-formatted.csv"


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