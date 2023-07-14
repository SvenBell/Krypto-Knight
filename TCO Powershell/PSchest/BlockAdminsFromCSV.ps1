cls

#This script removes admin users listed in input file from partner tenancies

Connect-MsolService #-Credential $cred

#Filename is the csv with user list heading UPN
#Heading UPN and Number and CallerID are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
$Filename = "C:\temp\BlockAdminUserList.csv"
# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date
pause

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
    Break
}

 
# This is the username of an Office 365 account with delegated admin permissions
 
#$UserName = "training@gcits.com"
 
#$Cred = get-credential -Credential $UserName
 

 
 
ForEach ($user in $users) {
 
    $tenantID = $user.tenantid
    $upn = $user.EmailAddress
    $i = $i + 1
    $error.clear()
    write-host "$i. Blocking sign in for:" $upn "" -foregroundcolor Yellow -NoNewline
 
    #Write-Output "Blocking sign in for: $upn"

    Try {
        Set-MsolUser -TenantId $tenantID -UserPrincipalName $upn -BlockCredential $true
    }
    Catch {}
    if (!$error) {
        Start-Sleep -Milliseconds 2000
        write-host "`r$i. Blocked user:" $upn " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
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