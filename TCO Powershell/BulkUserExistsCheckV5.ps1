#14/06/2021 Andrew Baird
#V4 23/07/2021 Enhances by Stephen Bell
# V5 30/08/2022 Add GDAP Support
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
#Connect-MsolService
#Connect-PartnerCenter

<# region   [System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }

#Show-Colors #>

#Filename is the csv with user list heading UPN
#Heading UPN and Number and CallerID are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
write-host "Preparing..."
Write-host ""
$Filename = "\\tsclient\C\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\PCYC Queensland\PR2614-TIPTandUCSolution\TCO Project Templates\NumberAssignments.csv"
$TenantID = "e246235b-d301-41f8-b9dd-756c6ac9b294"
#Connect-MicrosoftTeams -TenantId $TenantID #Customers Tenant ID
#Connect-AzureAD -TenantID $TenantID
####Connect-MsolService  #Connect to Entag but use -TenantID switch to execute commands against customer tenany ID
#Connect-PartnerCenter #Sign in as ENTAG Partner Portal admin
$TenantInfo = Get-PartnerCustomer -CustomerId $TenantID
$language = "en-AU"

#########################################

write-host "Tenant Name: " $TenantInfo.Name "  Tenant Domain: " $TenantInfo.Domain "  Tenant ID: " $TenantInfo.CustomerID
$confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]: "
while($confirmation1 -ne "y")
{
    if ($confirmation1 -eq 'n') {break}
    $confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]: "
}

$confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename " [y/n]: "
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename " [y/n]: "
}
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
    Break
}

### Process all users in .csv file ###
ForEach ($user in $users) {
    $upn = $user.UPN
    $number = $user.Number
    $callerid = $user.CallerID
    $i = $i + 1
    $error.clear()
    write-host "$i. Checking user:" $upn $number $callerid "" -foregroundcolor Yellow -NoNewline
    Try {
        #Set users Voice Routing Policy to $Null which is Global default policy
        #Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null -Verbose      
        #Assign user a telephone number
        #Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number -Verbose
        #Grant-CsCallingLineIdentity -Identity $upn -PolicyName $callerid -verbose
        $userdetails = Get-AzureADUser -ObjectID $upn | Select DisplayName, UserPrincipalName, UsageLocation
        #$userdetails = Get-MsolUser -UserPrincipalName $upn
        #$userdetails = Get-MsolUser -TenantId $tenantID -UserPrincipalName $upn
    }
    Catch {}
    if (!$error) {
        Start-Sleep -Milliseconds 2000
        write-host "`r$i. Checked user:" $upn $number $callerid " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
        write-host "`r$i. Error user:" $upn $number $callerid " " -foregroundcolor Red
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
#Get-MsolAccountSku -TenantId $tenantID
Get-AzureADSubscribedSku
#    Remove-PSSession