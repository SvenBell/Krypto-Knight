#20/07/2021 Andrew Baird
#V4 23/07/2021 Enhances by Stephen Bell
#Reach out if there are any issues or refinements needed


#Connect to Microsoft Teams Module
#Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\THE BMD GROUP\TCO Project Docs\Customer Facing_Link_Shared\Migration Sheets\Service_Upload20210729.csv"
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
Write-Host "Bulk Assign Resource Account Phone numbers and Set CallRoutePolicy "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total Resource Accounts to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$LinesInFile" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    Break
}

#for each user line in users table do the following
foreach ($user in $users) {
    #Create variables from csv columns
    #$aaname = $user.aaname
    $number = $user.Number
    $upn = $user.UPN
    $i = $i + 1
    $error.clear()
    #
    write-host "$i. Assigning" $upn $number "" -foregroundcolor Yellow -NoNewline
    #Set phone number to resource account with error listing
    Set-CsOnlineVoiceApplicationInstance -identity $upn -TelephoneNumber $number -ErrorAction silentlycontinue -Verbose

    if ($? -ne 'False') {
        write-host 'Display Name' $upn -ForegroundColor Red
        write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
        $errorcount = $errorcount + 1
        #Closing 1st if loop
    }
    else {
        #Display line to track progress through foreach loop
        write-host 'Assigned number' $number 'to' $upn -ForegroundColor Green
        #Closing 1st else loop
    }
    #
    #
    #
    write-host "$i. Assigning" $upn "Voice Routing Policy " -foregroundcolor Yellow -NoNewline
    #Grant VoiceRouting Policy with error listing
    Grant-CsOnlineVoiceRoutingPolicy -identity $upn -PolicyName $Null -Verbose
    if ($? -ne 'False') {
        write-host 'Resource Account' $upn -ForegroundColor Red
        write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
        $errorcount = $errorcount + 1
        #Closing 2nd if loop
    }
    else {
        #Display line to track progress through foreach loop
        write-host 'Assigned Global Voice route Policy to' $upn -ForegroundColor Cyan
        #Closing 2nd else loop
    }
    $Prog = [int]($i / $linesInFile * 100)
    Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
    #Closing for each loop
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

#Disconnect-MicrosoftTeams