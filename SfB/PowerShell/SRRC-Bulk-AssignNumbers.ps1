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


#############################################################################################################
#
# Bulk Assign numbers to users
#
#############################################################################################################
#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
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
    write-host "Error importing .csv file: " $FileName -foregroundcolor Red
    Break
}

### Process all users in .csv file ###
ForEach ($user in $users) {
    $upn = $user.UPN
    $number = $user.Number
    $i = $i + 1
    $error.clear()
    #$loc= $user.LocationID
    $loc=Get-CsOnlineLisLocation -Description "Beaudesert Admin Centre" # comment this out if you have
    write-host "$i. Assigning" $upn $number "" -foregroundcolor Yellow -NoNewline
    Try {
        #Set users Voice Routing Policy to $Null which is Global default policy
        #Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null #-Verbose
        #Next two lines for Direct Route Teams users      
        #Set-CsUser -Identity $UPN -OnPremLineURI $Null
        #Set-CsUser -Identity $UPN -OnPremLineURI TEL:$number
        #Assign Teams Call Plan user a telephone number
        #Get-CsOnlineUser -Identity $UPN | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
        
        Set-CsPhoneNumberAssignment -Identity $upn -PhoneNumber $number -LocationId $loc.Description -PhoneNumberType OperatorConnect #-verbose CallingPlan / OperatorConnect
    }
    Catch {}
    if (!$error) {
        #Start-Sleep -Milliseconds 2000
        write-host "`r$i. Assigned" $upn $number " LocationID: " $loc " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
        write-host "`r$i. # Assigning Error" $upn $number " LocationID: " $loc.LocationID " " -foregroundcolor Red
        #read-host “Press ENTER to continue: "
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
Write-Host ""

