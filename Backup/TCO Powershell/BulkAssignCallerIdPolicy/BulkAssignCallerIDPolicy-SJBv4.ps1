﻿#14/06/2021 Andrew Baird
#V2 23/07/2021 Enhances by Stephen Bell
#v4 23/05/2022 Only process lines with CallerID specified
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
### End Functions ###

#Connect-MicrosoftTeams

<# region   [System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }

#Show-Colors #>

#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\PROTECTOR ALUMINIUM PTY LTD\PR2492-TCO\Project Templates\NumberAssignments.csv"
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
Write-Host "Bulk Assign Caller-ID policy to users "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total assignments to process: " -NoNewline -ForegroundColor Yellow
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
    #$number = $user.Number
    $CallerIDPolicy = $user.CallerID
    $i = $i + 1
    $error.clear()
    if ($CallerIDPolicy -ne "") {
        write-host "$i. Assigning" $upn " CallerID policy: " $CallerIDPolicy "" -foregroundcolor Yellow -NoNewline
        Try {
            #Set users Voice Routing Policy to $Null which is Global default policy
            #Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null #-Verbose
            #Next two lines for Direct Route Teams users      
            #Set-CsUser -Identity $UPN -OnPremLineURI $Null
            #Set-CsUser -Identity $UPN -OnPremLineURI TEL:$number
            #Assign Teams Call Plan user a telephone number
            #Get-CsOnlineUser -Identity $UPN | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
            #Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number -Verbose
            #Set-CsPhoneNumberAssignment -Identity $upn -PhoneNumber $number -PhoneNumberType CallingPlan -verbose
            Grant-CsCallingLineIdentity -identity $upn -PolicyName $CallerIDPolicy
        }
        Catch {}
        if (!$error) {
            #Start-Sleep -Milliseconds 2000
            write-host "`r$i. Assigned" -foregroundcolor Green
        }
        else {
            $errorcount = $errorcount + 1
        }
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
write-host "CallerID Policies Assigned: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
#    Remove-PSSession