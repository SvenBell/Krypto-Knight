#14/06/2021 Andrew Baird
#V4 23/07/2021 Enhances by Stephen Bell
#V5 5/6/2023 Added extra fields for Operator connect: Phine NumberType, Location, CallerID
#v6 Added inout file UPN validation check prior to number assignemnt
#Reach out if there are any issues or refinements needed

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
$Filename = "C:\Users\StephenBell\Entag Group\Projects - Customer Projects\Bentleys Sunshine Coast\PR2991-De merger ICT and TCO\LD29766-WOB\Project Docs\OC\NumberAssignments.csv"
# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date


read-host “Checking all user object UPN's exist before processing assignments, press Enter to continue or Ctrl-C to exit”

#############################################################################################################
#
# Check all user object UPN's exist before processing assignments
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
Write-Host "Bulk check users exist "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total user assignments to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$LinesInFile" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    write-host "Error importing .csv file: " $FileName -foregroundcolor Red
    Break
}

### Process all users in .csv file ###
ForEach ($user in $users) {
    $upn = $user.UPN
    $number = $user.Number
    $i = $i + 1
    $error.clear()
    write-host "$i. Checking user:" $upn $number $callerid "" -foregroundcolor Yellow -NoNewline
    Try {
        #Set users Voice Routing Policy to $Null which is Global default policy
        #Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null -Verbose      
        #Assign user a telephone number
        #Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number -Verbose
        #Grant-CsCallingLineIdentity -Identity $upn -PolicyName $callerid -verbose
        #$userdetails = Get-CsOnlineUser -TenantId $tenantID -identity $upn | Select DisplayName,UserPrincipalName -verbose
        $userdetails = Get-CsOnlineUser -Identity $upn | Select DisplayName, UserPrincipalName
        #$userdetails = Get-AzureADUser -ObjectID $upn | Select DisplayName, UserPrincipalName, UsageLocation
        #$userdetails = Get-MsolUser -UserPrincipalName $upn
        #$userdetails = Get-MsolUser -TenantId $tenantID -UserPrincipalName $upn
    }
    Catch {}
    if (!$error) {
        Start-Sleep -Milliseconds 2000
        write-host "`r$i. Checked user:" $upn $number $userdetails.UsageLocation " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
        write-host "`r$i. Error user:" $upn $number " " -foregroundcolor Red
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

read-host "Press ENTER to continue...Bulk Assign Phone System & TCO Licenses to users, press Enter to continue or Ctrl-C to exit"


#############################################################################################################
#
# process User number assignments
#
#############################################################################################################

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
Write-Host "Bulk Assign numbers to users "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total phonenumber assignments to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$LinesInFile" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    Break
}

### Process all users in .csv file ###
ForEach ($user in $users) {
    $upn = $user.UPN
    $number = $user.Number
    $PhoneNumberType = $user.PhoneNumberType
    $Location = $user.Location
    $i = $i + 1
    $error.clear()
    write-host "$i. Assigning" $upn $number "" -foregroundcolor Yellow -NoNewline
    Try {
        #Set users Voice Routing Policy to $Null which is Global default policy
        #Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null #-Verbose
        #Next two lines for Direct Route Teams users      
        #Set-CsUser -Identity $UPN -OnPremLineURI $Null
        #Set-CsUser -Identity $UPN -OnPremLineURI TEL:$number
        #Assign Teams Call Plan user a telephone number
        #Get-CsOnlineUser -Identity $UPN | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
        #Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number -Verbose
        #Set-CsPhoneNumberAssignment -Identity $upn -PhoneNumber $number -PhoneNumberType CallingPlan
        $loc=Get-CsOnlineLisLocation -Description $Location
        Set-CsPhoneNumberAssignment -Identity $upn -PhoneNumber $number -LocationId $loc.LocationId -PhoneNumberType $PhoneNumberType
        #-verbose
    }
    Catch {}
    if (!$error) {
        #Start-Sleep -Milliseconds 2000
        write-host "`r$i. Assigned" $upn $number " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
        write-host "`r$i. Error Assigning " $upn $number " " -foregroundcolor Red
        read-host "press Enter to continue or Ctrl-C to exit"
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