
#$Credential = Get-Credential
#install-module msonline
Connect-MicrosoftTeams
#Connect-MsolService

$state = read-host -Prompt "Which state holidays? e.g. qld,vic,nsw,wa,sa,nt"

Switch ($state)
        {
        qld {
        #Starting with New Years for QLD
        $newyears = New-CsOnlineDateTimeRange -Start "1/01/2022 0:00" -End "2/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "QLD Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'QLD'
        Write-Host "-------"
        }
        nsw {
        #Starting with New Years for NSW
        $newyears = New-CsOnlineDateTimeRange -Start "1/01/2022 0:00" -End "2/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "NSW Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'NSW'
        Write-Host "-------"
        }
        vic {
        #Starting with New Years for VIC
        $newyears = New-CsOnlineDateTimeRange -Start "1/01/2022 0:00" -End "2/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "VIC Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'VIC'
        Write-Host "-------"
        }
        wa {
        #Starting with New Years for WA
        $newyears = New-CsOnlineDateTimeRange -Start "1/01/2022 0:00" -End "2/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "WA Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'WA'
        Write-Host "-------"
        }
        sa {
        #Starting with New Years for SA
        $newyears = New-CsOnlineDateTimeRange -Start "3/01/2022 0:00" -End "4/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "SA Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'SA'
        Write-Host "-------"
        }
        tas {
        #Starting with New Years for TAS
        $newyears = New-CsOnlineDateTimeRange -Start "1/01/2022 0:00" -End "2/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "TAS Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'TAS'
        Write-Host "-------"
        }
        nt {
        #Starting with New Years for NT
        $newyears = New-CsOnlineDateTimeRange -Start "1/01/2022 0:00" -End "2/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "NT Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'NT'
        Write-Host "-------"
        }
        act {
        #Starting with New Years for ACT
        $newyears = New-CsOnlineDateTimeRange -Start "1/01/2022 0:00" -End "2/01/2022 0:00"
        $schedule = New-CsOnlineSchedule -name "ACT Public Holidays 2022" -Fixedschedule -DateTimeRanges $newyears
        write-host 'ACT'
        Write-Host "-------"
        }
        Default{}
        }




#Load csv with all state holidays
$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\Holidays\Holidays2022-AllStates.csv"

$statefile = Import-Csv $FileName
#Filter csv with inputed state
$filteredstates = ($statefile | Where-Object { $_.state -eq $state})
#for each only for filtered state
foreach ($holiday in $filteredstates)
    {
    $name = $holiday.name
    $state = $holiday.state 
    $start= $holiday.startdate
    $end= $holiday.enddate
    $schedule.Fixedschedule.DateTimeRanges += New-CsOnlineDateTimeRange -Start "$start" -End "$end"
    Set-csonlineSchedule -Instance $schedule
    Write-host "adding schedule for" $name 

    }
    $schedule = ""

#write-host $name, $state| Format-Table | Out-String | Write-Host

#GET-PSSession | Remove-PSSession