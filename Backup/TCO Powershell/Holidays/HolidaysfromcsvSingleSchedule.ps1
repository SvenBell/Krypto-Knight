
#$Credential = Get-Credential
Import-Module SkypeOnlineConnector
#install-module msonline
Import-Module "C:\Program Files\Common Files\Skype for Business Online\Modules\SkypeOnlineConnector\SkypeOnlineConnector.psd1"
#Connect-MsolService
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession -AllowClobber

#$newyears = New-CsOnlineDateTimeRange -Start "1/01/2021 00:00" -End "1/01/2021 23:45"
$schedule = New-CsOnlineSchedule -name "QLD Holidays 2021" -Fixedschedule -DateTimeRanges $newyears


$Filename = "C:\Temp\QLDHolidays2021.csv"


    $dates = Import-Csv $FileName
    foreach ($date in $dates)
    {
        $name = $date.name
        $start= $date.start
        $end= $date.end
        $schedule.Fixedschedule.DateTimeRanges += New-CsOnlineDateTimeRange -Start "$start" -End "$end"
        Set-csonlineSchedule -Instance $schedule


    }

Remove-PSSession $sfboSession