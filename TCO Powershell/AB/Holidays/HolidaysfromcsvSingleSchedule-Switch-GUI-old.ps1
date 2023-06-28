Add-Type -AssemblyName PresentationFramework

#Create empty hashtable into which we will place the GUI objects
$wpf = @{ }




# where is the XAML file?
$xamlFile = "C:\Users\AndrewBaird\source\repos\WinFormsHolidays2022\WpfApp1-holidays\MainWindow.xaml"

#create window
$inputXML = Get-Content $xamlFile -Raw
$inputXMLclean = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXMLclean

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $tempform = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}


#$xaml.GetType().Fullname



# Create variables based on form control names.
# Variable will be named as 'var_<control name>'

#$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
#    #"trying item $($_.Name)"
#   try {
#        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Skip
#
#    } catch {
#        throw
#    }
#}
#Get-Variable var_*


#select each named node using an Xpath expression.
$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")


#add all the named nodes as members to the $wpf variable, this also adds in the correct type for the objects.
$namedNodes | ForEach-Object {

	$wpf.Add($_.Name, $tempform.FindName($_.Name))

}



#region RadioButton
$wpf.qld.add_Checked({
		
    #$this | Export-Clixml "$path\this.xml"
    #$_ | Export-Clixml "$path\DollarUnderscore.xml"
    $wpf.submitbtn.IsEnabled=$True
    #$wpf.FinishTextBlockHypervisor.text = $this.content
    #$statecontent= $this.content
    $state = "qld"

})
$state

$wpf.nsw.add_Checked({
        
        #$wpf.FinishTextBlockHypervisor.text = $this.content
        $wpf.submitbtn.IsEnabled=$True
        #$statecontent= $this.content
        $state = "nsw"
    })

$wpf.vic.add_Checked({
        
        #$wpf.FinishTextBlockHypervisor.text = $this.content
        $wpf.submitbtn.IsEnabled=$True
        #$statecontent= $this.content
        $state = "vic"
    })


#endregion




$Null = $tempform.ShowDialog()

$wpf.output.text = Write-output "adding schedule for"


#$Credential = Get-Credential
#install-module msonline
Connect-MicrosoftTeams
#Connect-MsolService

#$state = read-host -Prompt "Which state holidays? e.g. qld,vic,nsw,wa,sa,nt"

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
    $wpf.output.textinput = Write-output "adding schedule for" $name 

    }
    $schedule = ""

#write-host $name, $state| Format-Table | Out-String | Write-Host

#GET-PSSession | Remove-PSSession