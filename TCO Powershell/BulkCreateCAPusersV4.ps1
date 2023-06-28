#14/06/2021 Andrew Baird
#V4 23/07/2021 Enhances by Stephen Bell
#Reach out if there are any issues or refinements needed
# to generate random password in excel use: =MID("BCDFGHJKLMNPQRSTVWXYZ",RANDBETWEEN(1,21),1)&MID("aeiou",RANDBETWEEN(1,5),1)&MID("bcdfghjklmnpqrstvwxyz",RANDBETWEEN(1,21),1)&RANDBETWEEN(10000,99999)

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
#Connect-MsolService

<# region   [System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }

#Show-Colors #>

#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\PCYC Queensland\PR2614-TIPTandUCSolution\TCO Project Templates\CreateCAPs.csv"
# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date

#Add the SKU id you want to add license for
#If you have issues with contain you can replace with -like if needed
$CAPsku = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOCAP" } | Select-Object AccountSkuid
$TCOSKU = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOPSTNEAU2" } | Select-Object AccountSkuid
#$MultiSKU = $CAPsku.AccountSkuId + "," + $TCOSKU.AccountSkuId
#$MultiSKU = "compassinstitute:MCOCAP"
#Command New-MsolUser doesn't like the combined license variable so had to remove and add a seperate line in the for each loop (works fine on command line, just not in script)

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk Create CAP users "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total CAP users to create: " -NoNewline -ForegroundColor Yellow
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
    $UPN=$user.UPN
    $FirstName=$user.FirstName
    $LastName=$user.LastName
    $DisplayName=$user.DisplayName
    $UsageLocation=$user.UsageLocation 
    $SKU=$user.SKU
    $Password=$user.Password
    $i = $i + 1
    $error.clear()
    write-host "$i. Creating" $upn "" -foregroundcolor Yellow -NoNewline
    Try {
        New-MsolUser -DisplayName $DisplayName -FirstName $FirstName -LastName $LastName -UserPrincipalName $UPN -UsageLocation $UsageLocation -LicenseAssignment $CAPSKU -Password $Password
    }
    Catch {}
    if (!$error) {
        #Start-Sleep -Milliseconds 2000
        write-host "`r$i. Created" $upn " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
    }
    Try {
        #Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $TCOSKU
        Set-CsPhoneNumberAssignment -Identity $UPN -EnterpriseVoiceEnabled $true
    }
    Catch {}
    if (!$error) {
        #Start-Sleep -Milliseconds 2000
        #write-host "`r$i. Created" $upn $number " " -foregroundcolor Green
        write-host "`r$i. EnterpriseVoice enabled" $upn " " -foregroundcolor Green
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
write-host "Users created: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
#    Remove-PSSession