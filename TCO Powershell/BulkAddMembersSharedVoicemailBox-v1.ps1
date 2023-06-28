#Bulk Add Shared Voicemail Box - PowerShell script
#v1 ready for Production use
#

#Connect-ExchangeOnline

#Customise for each customer
########################################
$Filename = "\\tsclient\C\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\PCYC Queensland\PR2614-TIPTandUCSolution\TCO Project Templates\BulkAddSharedVoicemailBox.csv"

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
	#$VmailOwners = $user.VmailOwners
    $VmailMembers = ""
	$VmailMembers = $user.VmailMembers1
    ##### Adjust # above to process additional number of members being added  ###########

	$i = $i + 1
	$error.clear()
    if ($VmailMembers -ne "") {
        write-host "$i. Adding member to Voicemail box: " $VmailDisplayName "" -foregroundcolor Yellow #-NoNewline
        Try {
		    #Create Microsoft365 Group for shared voicemail
		    #New-UnifiedGroup -AccessType Private -DisplayName $VmailDisplayName -Alias $VmailAlias -Notes $VmailNote -Owner $VmailOwner1 -ManagedBy $VmailOwner1,$VmailOwner2,$VmailOwner3,$VmailOwner4,$VmailOwner5 -Members $VmailMember1,$VmailMember2,$VmailMember3,$VmailMember4,$VmailMember5 -verbose
            #New-UnifiedGroup -AccessType Private -DisplayName $VmailDisplayName -Alias $VmailAlias -Notes $VmailNote -Owner $VmailOwner1 -ManagedBy $VmailOwner1 -Members $VmailMember1,$VmailMember2,$VmailMember3,$VmailMember4 -verbose
            Add-UnifiedGroupLinks -Identity $VmailDisplayName -LinkType Members -Links "$VmailMembers"
            #Add-UnifiedGroupLinks -Identity $VmailDisplayName -LinkType Owners -Links $VmailMembers
        }
        Catch {}
        if (!$error) {
            Write-host "`r$i. Added members to:  " $VmailDisplayName " " -foregroundcolor Green
		    Get-UnifiedGroup -Identity $VmailAlias | Format-List DisplayName,Alias,EmailAddresses,ManagedBy,AccessType,Notes
		    Write-Host "Voicemail box members:" 
		    Get-UnifiedGroupLinks -Identity $VmailAlias -LinkType Members
            Start-Sleep -Milliseconds 2000
        }
        else {
            $errorcount = $errorcount + 1
            Write-host "`r$i. Failed to Add members to Voicemail box:  " $VmailDisplayName " " -foregroundcolor Red
		    read-host "Press ENTER to continue: "
        }
        Try {
		    #Create Microsoft365 Group for shared voicemail
		    #New-UnifiedGroup -AccessType Private -DisplayName $VmailDisplayName -Alias $VmailAlias -Notes $VmailNote -Owner $VmailOwner1 -ManagedBy $VmailOwner1,$VmailOwner2,$VmailOwner3,$VmailOwner4,$VmailOwner5 -Members $VmailMember1,$VmailMember2,$VmailMember3,$VmailMember4,$VmailMember5 -verbose
            #New-UnifiedGroup -AccessType Private -DisplayName $VmailDisplayName -Alias $VmailAlias -Notes $VmailNote -Owner $VmailOwner1 -ManagedBy $VmailOwner1 -Members $VmailMember1,$VmailMember2,$VmailMember3,$VmailMember4 -verbose
            #Add-UnifiedGroupLinks -Identity $VmailDisplayName -LinkType Members -Links $VmailMembers
            Add-UnifiedGroupLinks -Identity $VmailDisplayName -LinkType Owners -Links $VmailMembers
        }
        Catch {}
        if (!$error) {
            Write-host "`r$i. Added owners Voicemail box:  " $VmailDisplayName " " -foregroundcolor Green
		    Get-UnifiedGroup -Identity $VmailAlias | Format-List DisplayName,Alias,EmailAddresses,ManagedBy,AccessType,Notes
		    Write-Host "Voicemail box Owners and members:" 
		    Get-UnifiedGroupLinks -Identity $VmailAlias -LinkType Owners
            Write-host ""
            Get-UnifiedGroupLinks -Identity $VmailAlias -LinkType Members
            Start-Sleep -Milliseconds 2000
            Write-host ""

            #read-host "Press ENTER to continue: "
        }
        else {
            $errorcount = $errorcount + 1
            Write-host "`r$i. Failed to Add owners Voicemail box:  " $VmailDisplayName " " -foregroundcolor Red
		    read-host "Press ENTER to continue: "
        }
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