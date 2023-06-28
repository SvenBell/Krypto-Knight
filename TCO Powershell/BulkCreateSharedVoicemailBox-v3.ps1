#Bulk Create Shared Voicemail Box - PowerShell script
#v3ready for Production use
#

#Connect-ExchangeOnline -DelegatedOrganization allenstraining.onmicrosoft.com
#Get-ConnectionInformation  # confirm connected to correct Exchange tenant
#

#Customise for each customer
########################################

#$Filename = "\\tsclient\C\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\White House Celebrations\PR2621-TCO\Project Templates\BulkCreateSharedVoicemailBox.csv"
$Filename = "C:\Users\StephenBell\Entag Group\Projects - Customer Projects\Torres Strait Regional Authority TSRA\PR2455-TCO\Project Documents\BulkCreateSharedVoicemailBox.csv"

########################################
#For testing
########################################

# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date

#Load timer function
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk Create O365 Voice Mailboxes "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total O365 Shared voicemail boxes to create: " -NoNewline -ForegroundColor Yellow
Write-Host "$LinesInFile" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    Break
}

#Connect-MSOLService
foreach ($user in $users) {
    $VmailDisplayName = $user.VmailDisplayName
    $VmailAlias = $user.VmailAlias
	$VmailNote = $user.VmailNote
	$VmailOwner1 = $user.VmailOwner1
	$VmailOwner2 = $user.VmailOwner2
	$VmailOwner3 = $user.VmailOwner3
	$VmailOwner4 = $user.VmailOwner4
	$VmailOwner5 = $user.VmailOwner5
	$VmailMember1 = $user.VmailMember1
	$VmailMember2 = $user.VmailMember2
	$VmailMember3 = $user.VmailMember3
	$VmailMember4 = $user.VmailMember4
	$VmailMember5 = $user.VmailMember5
	$i = $i + 1
	$error.clear()

    write-host "$i. Creating Voicemail box: " $VmailDisplayName "" -foregroundcolor Yellow #-NoNewline
    Try {
		#Create Microsoft365 Group for shared voicemail
		#New-UnifiedGroup -AccessType Private -DisplayName $VmailDisplayName -Alias $VmailAlias -Notes $VmailNote -Owner $VmailOwner1 -ManagedBy $VmailOwner1,$VmailOwner2,$VmailOwner3,$VmailOwner4,$VmailOwner5 -Members $VmailMember1,$VmailMember2,$VmailMember3,$VmailMember4,$VmailMember5 -verbose
        #New-UnifiedGroup -AccessType Private -DisplayName $VmailDisplayName -Alias $VmailAlias -Notes $VmailNote -Owner $VmailOwner1 -ManagedBy $VmailOwner1 -Members $VmailMember1,$VmailMember2,$VmailMember3,$VmailMember4 -verbose
        New-UnifiedGroup -AccessType Private -DisplayName $VmailDisplayName -Alias $VmailAlias -Notes $VmailNote -Owner $VmailOwner1 -ManagedBy $VmailOwner1 -Members $VmailMember1 -verbose

    }
    Catch {}
    if (!$error) {
        Write-host "`r$i. Created Voicemail box:  " $VmailDisplayName " " -foregroundcolor Green
		Get-UnifiedGroup -Identity $VmailAlias | Format-List DisplayName,Alias,EmailAddresses,ManagedBy,AccessType,Notes
		Write-Host "Voicemail box members:" 
		Get-UnifiedGroupLinks -Identity $VmailAlias -LinkType Members
        Start-Sleep -Milliseconds 2000
    }
    else {
        $errorcount = $errorcount + 1
        Write-host "`r$i. Failed to Create Voicemail box:  " $VmailDisplayName " " -foregroundcolor Red
		read-host "Press ENTER to continue: "
    }
	Start-Sleep -Milliseconds 2000
	$Prog = [int]($i / $linesInFile * 100)
    Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
}

### Summary
Start-Sleep -Milliseconds 2000
$FinishDate = get-Date
write-host ""; Write-Host "Completed processing"
$Interval = $FinishDate - $StartDate
"Script Duration: {0} HH:MM:SS" -f ($Interval.ToString())
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Finish Time: " -NoNewline -foregroundcolor Yellow
write-host "$FinishDate" -ForegroundColor Cyan
write-host "Mailboxes created: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""

# Disconnect-ExchangeOnline