# Author: 17/05/2023 Stephen Bell
# 
#
#
# Connect-MicrosoftTeams   #Before running script :)
# Reach out if there are any issues or refinements needed

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

#Connect-MicrosoftTeams

<# region   [System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }

#Show-Colors #>

#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
$Filename = "C:\Users\StephenBell\Entag Group\Projects - Customer Projects\Torres Strait Regional Authority TSRA\PR2455-TCO\Project Documents\CAllerID.csv"

read-host “Checking all resourceaccount UPN's exist before processing assignments, press Enter to continue or Ctrl-C to exit”

#############################################################################################################
#
# Check all Resource Account object UPN's exist before processing CallerID policy creation
#
#############################################################################################################

#Filename is the csv with user list heading UPN
#Heading UPN and Number and CallerID are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date


### Display Introduction ###
Write-host ""
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk CHECK create CallerID policies "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total polices to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$LinesInFile" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

### Import .csv file
Try {
    $items = Import-Csv $FileName
}
Catch {
    write-host "Error importing .csv file: " $FileName -foregroundcolor Red
    Break
}

write-host ""
$items | ft 
read-host “Press ENTER to continue...”

### Process all users in .csv file ###
ForEach ($item in $items) {
    $RAUPNPrefix = $item.RAUPNPrefix
    $RAUPNSuffix = $item.UPNSuffix
    $RAUPN = "$RAUPNPrefix@$RAUPNSuffix"
    $i = $i + 1
    $error.clear()
    write-host "$i. Checking CallerID destination:" $RAUPN "" -foregroundcolor Yellow -NoNewline
    Try {
        $ObjId = (Get-CsOnlineApplicationInstance -Identity $RAUPN).ObjectId
    }
    Catch {}
    if (!$error) {
        Start-Sleep -Milliseconds 2000
        write-host "`r$i. Checked CallerID Destination:" $RAUPN " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
        write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
    }
    $Prog = [int]($i / $linesInFile * 100)
    Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
}

### Summary
$FinishDate = get-Date
write-host ""; Write-Host "Completed processing"
$Interval = $FinishDate - $StartDate
"Script Duration: {0} HH:MM:SS" -f ($Interval.ToString())
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Finish Time: " -NoNewline -foregroundcolor Yellow
write-host "$FinishDate" -ForegroundColor Cyan
write-host "Users Assigned: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""

read-host "Press ENTER to continue...Bulk create CallerID policies"

# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk create CallerID policies "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total polices to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$LinesInFile" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

### Import .csv file
Try {
    $items = Import-Csv $FileName
}
Catch {
    Break
}

### Process all users in .csv file ###
ForEach ($item in $items) {
    $CIDPolicyName = $item.CIDPolicyName
    $CIDDescription = $item.CIDDescription
    $CallingIDSubstitute = $item.CallingIDSubstitute
    If ($item.EnableUserOverride -eq "Yes") {
		$EnableUserOverride = $true
	}
	Else {
		$EnableUserOverride = $false
    }
    If ($item.BlockIncomingPstnCallerID -eq "Yes") {
		$BlockIncomingPstnCallerID = $true
	}
	Else {
		$BlockIncomingPstnCallerID = $false
    }
    $CompanyName = $item.CompanyName
    $RAUPNPrefix = $item.RAUPNPrefix
    $RAUPNSuffix = $item.UPNSuffix
    $RAUPN = "$RAUPNPrefix@$RAUPNSuffix"
    $i = $i + 1
    $error.clear()
    write-host "$i. Creating CallerID policy:" $CIDPolicyName $RAUPN "" -foregroundcolor Yellow -NoNewline
    Try {
        $ObjId = (Get-CsOnlineApplicationInstance -Identity $RAUPN).ObjectId
        New-CsCallingLineIdentity -Identity $CIDPolicyName -Description $CIDDescription -CallingIDSubstitute $CallingIDSubstitute -EnableUserOverride $EnableUserOverride -ResourceAccount $ObjId -CompanyName $CompanyName
    }
    Catch {}
    if (!$error) {
        #Start-Sleep -Milliseconds 2000
        write-host "`r$i. Assigned" $CIDPolicyName $RAUPN " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
        write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
        read-host "Press ENTER to continue..."
    }
    $Prog = [int]($i / $linesInFile * 100)
    Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
}

### Summary
$FinishDate = get-Date
write-host ""; Write-Host "Completed processing"
$Interval = $FinishDate - $StartDate
"Script Duration: {0} HH:MM:SS" -f ($Interval.ToString())
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Finish Time: " -NoNewline -foregroundcolor Yellow
write-host "$FinishDate" -ForegroundColor Cyan
write-host "Numbers Assigned: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
#    Remove-PSSession