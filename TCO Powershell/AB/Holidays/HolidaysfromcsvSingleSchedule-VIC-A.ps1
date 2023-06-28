
#$Credential = Get-Credential
#install-module msonline
Connect-MicrosoftTeams
#Connect-MsolService


$newyears = New-CsOnlineDateTimeRange -Start "1/01/2021 00:00" -End "1/01/2021 23:45"
$schedule = New-CsOnlineSchedule -name "VIC Holidays 2021-A" -Fixedschedule -DateTimeRanges $newyears


$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\Holidays\Holidays2021-VIC-formatted-A.csv"


    $dates = Import-Csv $FileName
    foreach ($date in $dates)
    {
        $name = $date.name
        $start= $date.startdate
        $end= $date.enddate
        $schedule.Fixedschedule.DateTimeRanges += New-CsOnlineDateTimeRange -Start "$start" -End "$end"
        Set-csonlineSchedule -Instance $schedule


    }

Remove-PSSession $sfboSession