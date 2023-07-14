#Bulk Update existing CQ Agents
#v6 Added more parameters to new CQ cmdlet: -PresenceBasedRouting False
#
# Great reference site for PowerShell and Teams: https://robdy.io/automating-call-queues-and-auto-attendant-onboarding/
#
#v5 Added GDAP compatibility to script commands
# needs work on: $CQsTotal = (($users.CQRAName| measure).count)
# to display coorect number of CQs not including blank lines
#v6 AzureAD module and refinements
#

#$Credential = Get-Credential

#Connect-MicrosoftTeams
#Connect-AzureAD
#Connect-PartnerCenter  # Optional

#Customise for each customer
########################################
#$domain= "fkgardnersons.onmicrosoft.com"
write-host "Preparing..."
Write-host ""
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\PCYC Queensland\PR2614-TIPTandUCSolution\TCO Project Templates\BulkAACQ-test.csv"
$TenantID = "78cc49bc-eb7d-49bb-bbd0-f242721e720e"
#Connect-MicrosoftTeams -TenantId $TenantID
#Connect-AzureAD -TenantID $TenantID
#Connect-MsolService  #Connect to Entag but use -TenantID switch to execute commands against customer tenany ID
#Connect-PartnerCenter #Sign in as ENTAG Partner Portal admin
$TenantInfo = Get-PartnerCustomer -CustomerId $TenantID
$language = "en-AU"
#$timezone = "E. Australia Standard Time" # Now setup via .CSV file data
#
#NOTE:
#Conference mode will be turned on # Now setup via .CSV file data
#Allow opt out will be turned on # Now setup via .CSV file data
#TimeZone codes
#QLDStandardName            : E. Australia Standard Time
#WAStandardName             : W. Australia Standard Time
#NSW/VIC                    : AUS Eastern Standard Time
########################################


### Functions Section ###
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

########################################

write-host "Tenant Name: " $TenantInfo.Name "  Tenant Domain: " $TenantInfo.Domain "  Tenant ID: " $TenantInfo.CustomerID
$confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]"
while($confirmation1 -ne "y")
{
    if ($confirmation1 -eq 'n') {break}
    $confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]"
}

$confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename " [y/n]"
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename " [y/n]"
}


### Import .csv file
write-host "List of CQ's to process: "
Try {
    $users = Import-Csv $FileName
}
Catch {
    Break
}
write-host ""
$users | ft -Property CQ*,UPN*
read-host “Press ENTER to continue...”

######################################

#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$CQsTotal = (($users.CQRAName| measure).count)
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk updating existing CQ Agents "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total CQ's to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$CQsTotal" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

######################################

# Update existing CQs
    foreach ($user in $users) {
        $CQDisplayName = $user.CQDisplayName
        $CQName = $user.CQName
        $CQRAName = $user.CQRAName
        $CQUPNSuffix = $user.UPNSuffix
        $CQRAUPN = "$CQRAName@$CQUPNSuffix"
        $CQRoutingMethod = $user.CQRoutingMethod
        If ($user.CQAllowOptOut -eq "On") {
            $CQAllowOptOut = $true
        }
        Else {
            $CQAllowOptOut = $false
        }
		If ($user.CQPresenceBasedRouting -eq "Off") {
            $CQPresenceBasedRouting = $false
        }
        Else {
            $CQPresenceBasedRouting = $true
        }
        $CQAlertTime = $user.CQAlertTime
        $CQTimeout = $user.CQTimeout
        If ($user.CQConferenceMode -eq "On") {
            $CQConferenceMode = $true
        }
        Else {
            $CQConferenceMode = $false
        }
		$CQAgent1 = $user.CQAgent1
		$CQAgent2 = $user.CQAgent2
		$CQAgent3 = $user.CQAgent3
		if ($CQAgent1 -ne "") {
            $CQAgent1ID = (Get-CsOnlineUser -Identity $CQAgent1).Identity
        }
		if ($CQAgent2 -ne "") {
            $CQAgent2ID = (Get-CsOnlineUser -Identity $CQAgent2).Identity
		}
        if ($CQAgent3 -ne "") {
            $CQAgent3ID = (Get-CsOnlineUser -Identity $CQAgent3).Identity
        }		

        #read-host “Press ENTER to continue...”
        $i = $i + 1
        $error.clear()
		
		if ($CQRAName -ne "") {
            #Check Call Queue exists
            $LastCQRAUPN = $CQRAUPN
			#$CQid = (Get-CsCallQueue -NameFilter $CQName | Where-Object Name -eq $CQName).Identity
            write-host "$i. Checking CQ: " $CQRAUPN -foregroundcolor Yellow
            Try {
                $CQid = (Get-CsCallQueue -NameFilter $CQName | Where-Object Name -eq $CQName).Identity
            }
            Catch {}
            if (!$error) {
                write-host "`r$i. CQ Found: " $CQRAUPN -foregroundcolor Green
            }
            else {
                $errorcount = $errorcount + 1
                write-host $error
                read-host “Press ENTER to continue...”
            }
            $Prog = [int]($i / $linesInFile * 100)
            Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
        }
		
        if ($CQDisplayName -ne "") {
            #$LastCQUPN = $CQUPN
            #Update Call Queue settings
            write-host "$i. Creating CQ: " $CQDisplayName -foregroundcolor Yellow
            if ($CQAgent3 -ne "") {
				# Update 3 Agent CQ
                Try {
                    Set-CsCallQueue -Identity $CQid -Name $CQDisplayName -RoutingMethod $CQRoutingMethod -PresenceBasedRouting $CQPresenceBasedRouting -AllowOptOut $CQAllowOptOut -AgentAlertTime $CQAlertTime -TimeoutThreshold $CQTimeout -UseDefaultMusicOnHold $true -LanguageId $language -ConferenceMode $CQConferenceMode -Users $CQAgent1ID,$CQAgent2ID,$CQAgent3ID 
                }
                Catch {}
                if (!$error) {
                    write-host "`r$i. Created CQ: " $CQDisplayName " " -foregroundcolor Green
                }
                else {
                    $errorcount = $errorcount + 1
                    write-host $error
                    read-host “Press ENTER to continue...”
                }
            }
            else {
				# Update 2 Agent CQ
                Try {
                    Set-CsCallQueue -Identity $CQid -Name $CQDisplayName -RoutingMethod $CQRoutingMethod -PresenceBasedRouting $CQPresenceBasedRouting -AllowOptOut $CQAllowOptOut -AgentAlertTime $CQAlertTime -TimeoutThreshold $CQTimeout -UseDefaultMusicOnHold $true -LanguageId $language -ConferenceMode $CQConferenceMode -Users $CQAgent1ID,$CQAgent2ID 
                }
                Catch {}
                if (!$error) {
                    write-host "`r$i. Created CQ: " $CQDisplayName " " -foregroundcolor Green
                }
                else {
                    $errorcount = $errorcount + 1
                    write-host $error
                    read-host “Press ENTER to continue...”
                }
            }
        }

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
write-host "CQ's updated: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
Write-Host ""

#    Remove-PSSession $sfboSession
