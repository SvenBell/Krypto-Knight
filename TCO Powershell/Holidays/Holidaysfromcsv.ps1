
$Credential = Get-Credential
#Import-Module SkypeOnlineConnector
#install-module msonline
Import-Module "C:\Program Files\Common Files\Skype for Business Online\Modules\SkypeOnlineConnector\SkypeOnlineConnector.psd1"
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession -AllowClobber


$Filename = "C:\Temp\QLDHolidays.csv"


    $dates = Import-Csv $FileName
    foreach ($date in $dates)
    {
        $name = $date.name
        $start= $date.start
        $end= $date.end
        $dtr = New-CsOnlineDateTimeRange -Start "$start" -End "$end"
        New-CsOnlineSchedule -Name "$name" -FixedSchedule -DateTimeRanges @($dtr)


    }

Remove-PSSession $sfboSession