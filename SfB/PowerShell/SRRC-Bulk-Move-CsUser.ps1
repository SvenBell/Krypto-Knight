write-host "Preparing..."
Write-host ""
$Filename = "C:\temp\SRRC-Move-CsUsersB.csv"
$language = "en-AU"


$confirmation2 = Read-Host "Are you happy with this file location for the CSV? " $Filename " [y/n]: "
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV? " $Filename " [y/n]: "
}
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
$UPNerrorcount = 0
$UserNotLicensedCount = 0
$USerTotallyUnlicensed = 0
$UserAccountDisabled = 0
$i = 0
$Prog = 0
$StartDate = get-Date

Write-host "Please authenticate to Microsoft 365 when prompted..."
#$cred=Get-Credential
$url="https://adminau1.online.lync.com/HostedMigration/hostedmigrationService.svc"

### Display Introduction ###
Write-host ""
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk Move SfB users to Teams "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total Users to move: " -NoNewline -ForegroundColor Yellow
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
    $i = $i + 1
    $error.clear()
    #write-host "$i. Moving user:" $upn "" -foregroundcolor Yellow -NoNewline
    write-host "$i. Disabling SfB user:" $upn "" -foregroundcolor Yellow -NoNewline
    Try {
        Move-CsUser -Identity $upn -Target sipfed.online.lync.com -Credential $cred -HostedMigrationOverrideUrl $url -Confirm:$False -Verbose
        #Disable-CsUser -Identity $upn -Verbose
    }
     Catch {}
     if (!$error) {
        write-host "`r    User Moved Successfully: " $upn -foregroundcolor Green
         }
     else {
         $errorcount = $errorcount+1
         write-host  "Disabling SfB user:" $upn "" 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
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
write-host "Users Processed: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
Write-Host ""

#Start-Sleep -Milliseconds 120000
Write-Host ""