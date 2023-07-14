# Filename: ImportDNSrecordsFromCSVtoAZ-v1.ps1
#
# 02/06/2022 Stephen Bell
#
# Please Reach out if there are any issues or refinements needed

##########################################################
#
# Variables to be changed to suit each customer
#
##########################################################
$CSVFilename = "C:\Tools\GitHub\PowerShell\domain\ZoneRecords.csv"
$ResourceGroupName = 'dns-rg'
$ZoneName          = 'octfol.io'

### Functions ###
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while ($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}
function Show-Colors( ) {
    $colors = [System.Enum]::GetValues( [System.ConsoleColor] )
    $max = ($colors | ForEach-Object { "$_ ".Length } | Measure-Object -Maximum).Maximum
    foreach ( $color in $colors ) {
        Write-Host (" {0,2} {1,$max} " -f [int]$color, $color) -NoNewline
        Write-Host "$color" -Foreground $color
    }
}
Function Pause ($Message = "Press any key to continue...") {
   # Check if running in PowerShell ISE
   If ($psISE) {
      # "ReadKey" not supported in PowerShell ISE.
      # Show MessageBox UI
      $Shell = New-Object -ComObject "WScript.Shell"
      $Button = $Shell.Popup("Click OK to continue.", 0, "Hello", 0)
      Return
   }
 
   $Ignore =
      16,  # Shift (left or right)
      17,  # Ctrl (left or right)
      18,  # Alt (left or right)
      20,  # Caps lock
      91,  # Windows key (left)
      92,  # Windows key (right)
      93,  # Menu key
      144, # Num lock
      145, # Scroll lock
      166, # Back
      167, # Forward
      168, # Refresh
      169, # Stop
      170, # Search
      171, # Favorites
      172, # Start/Home
      173, # Mute
      174, # Volume Down
      175, # Volume Up
      176, # Next Track
      177, # Previous Track
      178, # Stop Media
      179, # Play
      180, # Mail
      181, # Select Media
      182, # Application 1
      183  # Application 2
 
   Write-Host -NoNewline $Message
   While ($KeyInfo.VirtualKeyCode -Eq $Null -Or $Ignore -Contains $KeyInfo.VirtualKeyCode) {
      $KeyInfo = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
   }
}
### End Functions ###

#Connect-AzAccount

write-host ""
write-host "Running: ImportDNSrecordsFromCSVtoAZ" -foregroundcolor Yellow
write-host ""
write-host "Are you happy with this file location for the CSV? (y/n) " -NoNewline -foregroundcolor Yellow
$confirmation2 = Read-Host " " $CSVFilename
while($confirmation2 -ne "y") {
    if ($confirmation2 -eq 'n') {break}
    write-host "Are you happy with this file location for the CSV? (y/n) " -NoNewline -foregroundcolor Yellow
    $confirmation2 = Read-Host " " $CSVFilename
}


##########################################################
#
# Import .csv file
#
# CSV file headers required: Name, RecordType, ZoneName, ResourceGroup, Value, TTL, Preference, Weight, Port
#
##########################################################
### 
Try {
    $Records = Import-Csv $CSVFileName
}
Catch {
    Break
}
write-host ""
$Records | ft -Property Name, ZoneName, RecordType, ttl, Value, TargetResourceId, ResourceGroupName

write-host ""
$confirmation3 = Read-Host "Are you happy to process the CSV's DNS records above? (y/n) "
while($confirmation3 -ne "y") {
    if ($confirmation3 -eq 'n') {break}
    $confirmation3 = Read-Host "Are you happy to process the CSV's DNS records above? (y/n) "
}


write-host ""
read-host “Press ENTER to Display Existing DNS records sets”

##########################################################
#
# Display current DNS Zone record sets
#
##########################################################
$recordsets = Get-AzDnsRecordSet -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName

$recordsets | ft Name, ZoneName, RecordType, ttl, Value, TargetResourceId, ResourceGroupName

######################################

write-host ""
read-host “Press ENTER to begin import of new DNS record sets”

#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
# Establish Progress variables
$fileStats = Get-Content $CSVFilename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$DNSRecordsTotal = (($Records.Name| measure).count)
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk create import and creation of DNS records "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total DNS records to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$DNSRecordsTotal" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

######################################

##########################################################
#
# Add new DNS Records from .CSV
#
##########################################################
$Records = Import-CSV -Path $CSVFilename
foreach ($Record in $Records) 
    {
    $i = $i + 1
    $error.clear()
    switch ($Record.RecordType) 
        {
        "A" { New-AzDnsRecordSet -Name $Record.Name -RecordType $Record.RecordType -ZoneName $Record.ZoneName -ResourceGroupName $Record.ResourceGroup -Ttl $Record.TTL -DnsRecords (New-AzDnsRecordConfig -IPv4Address $Record.Value) ;Break } 
        "CNAME" { New-AzDnsRecordSet -Name $Record.Name -RecordType $Record.RecordType -ZoneName $Record.ZoneName -ResourceGroupName  $Record.ResourceGroup -Ttl $Record.TTL -DnsRecords (New-AzDnsRecordConfig -Cname $Record.Value) ;Break } 
        "TXT" { New-AzDnsRecordSet -Name $Record.Name -RecordType $Record.RecordType -ZoneName $Record.ZoneName -ResourceGroupName  $Record.ResourceGroup -Ttl $Record.TTL -DnsRecords (New-AzDnsRecordConfig -Value $Record.Value) ;Break } 
        "MX" { New-AzDnsRecordSet -Name $Record.Name -RecordType $Record.RecordType -ZoneName $Record.ZoneName -ResourceGroupName  $Record.ResourceGroup -Ttl $Record.TTL -DnsRecords (New-AzDnsRecordConfig -Exchange $Record.Value -Preference $Record.Preference) ;Break } 
        "SRV" { New-AzDnsRecordSet -Name $Record.Name -RecordType $Record.RecordType -ZoneName $Record.ZoneName -ResourceGroupName  $Record.ResourceGroup -Ttl $Record.TTL -DnsRecords (New-AzDnsRecordConfig -Priority $Record.Preference  -Weight $Record.Weight -Port $Record.Port   -Target $Record.Value) ;Break }                             
        Default { 
             Write-host "The record " $Record.Name " type is " $Record.RecordType " and can't be created"
             $errorcount = $errorcount + 1
             write-host $error
             read-host “Press ENTER to continue...”
                }
 
        }
    if (!$error) {
                write-host "`r$i. Created " $Record.Name -foregroundcolor Green
            }
    else {
                $errorcount = $errorcount + 1
                write-host $error
                read-host “Press ENTER to continue...”
            }
    $Prog = [int]($i / $linesInFile * 100)
    Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)     
    }

##########################################################
#
### Summary
#
##########################################################

$FinishDate = get-Date
write-host ""; Write-Host "Completed processing"
$Interval = $FinishDate - $StartDate
"Script Duration: {0} HH:MM:SS" -f ($Interval.ToString())
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Finish Time: " -NoNewline -foregroundcolor Yellow
write-host "$FinishDate" -ForegroundColor Cyan
write-host "CQ Resource accounts created: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""

read-host “Press ENTER to List new Current DNS Zone records”
##########################################################
#
# Display current DNS Zone record sets
#
##########################################################
$recordsets = Get-AzDnsRecordSet -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName

$recordsets | ft Name, ZoneName, RecordType, ttl, Value, TargetResourceId, ResourceGroupName