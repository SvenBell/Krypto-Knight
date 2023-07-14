##############################
# Bulk create Auto Attendants (AAs) for Teams
# v4 Stephen Bell - Now builds from .CSV file handling multiple Resource Accounts per AA
# v5 adds GDAP support - some MS commands need trouble shooting permissions...
# v6 AzureAD module and refinements
# v7 added additional .csv configurable attributes
#
##############################

# First connect to correct Tenancy
#Connect-MicrosoftTeams
#Connect-MsolService
#Connect-PartnerCenter

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
# Check these variables
#$domain= "hinchinbrook.onmicrosoft.com" #Best if you use .onmicrosoft.com domain so phone don't die if DNS reg issues
write-host "Preparing..."
Write-host ""
$Filename = "C:\Users\StephenBell\Entag Group\Projects - Customer Projects\ALLEN'S TRAINING PTY LTD\LD26214 - TCO + TID\PR2857 - TCO365\Project Templates\BulkAACQ.csv"
$TenantID = "7decc850-54f1-40bf-ada5-ed61fcf59721"
#Connect-MicrosoftTeams -TenantId $TenantID
#Connect-AzureAD -TenantID $TenantID
##Connect-MsolService  #Connect to Entag but use -TenantID switch to execute commands against customer tenany ID
#Connect-PartnerCenter #Sign in as ENTAG Partner Portal admin
$TenantInfo = Get-PartnerCustomer -CustomerId $TenantID
$language = "en-AU"
#$timezone = y"E. Australia Standard Time" # Now in input .csv file

#TimeZone codes
#QLDStandardName               : E. Australia Standard Time
#WAStandardName               : W. Australia Standard Time
#NSW/VIC                    : AUS Eastern Standard Time
########################################
#########################################

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


$confirmation3 = Read-Host "Have you set the correct License Type i.e. Retail/Faculty/NFP? [y/n]"
while($confirmation3 -ne "y")
{
    if ($confirmation3 -eq 'n') {break}
    $confirmation2 = Read-Host "Have you set the correct License Type i.e. Retail/Faculty/NFP? [y/n]"
}

### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    write-host "File import error"
    Break
}
write-host ""
$users | ft -Property AA*,UPN*
read-host “File imported, Press ENTER to continue...”

######################################
    #Create AutoAttendant and Resource Account
    foreach ($user in $users)
    {

        $AADisplayName = $user.AADisplayName
        $AAName = $user.AAName
        $AATimeZone = $user.AATimeZone
        $RADisplayName = $user.AARADisplayName
        $RAUPNPrefix = $user.AARAUPNPrefix
        $UPNSuffix = $user.UPNSuffix
        $RAUPN = "$RAUPNPrefix@$UPNSuffix"
		$AAOperatorType = $user.AAOperatorType
		$AAOperatorName = $user.AAOperatorName
		$AAGreetingTxt = $user.AAGreetingTxt
		$AAAHGreetingTxt = $user.AAAHGreetingTxt
		$AAPHGreetingTxt = $user.AAPHGreetingTxt
		$AAOperatorType = $user.AAOperatorType
		$AAOperatorName = $user.AAOperatorName
		$AAPublicHolidaysName = $user.AAPublicHolidaysName
		$AAVoicemail = $user.AAVoicemail
		$AATargetName = $user.AATargetName
        $AAUPNSuffix = $user.UPNSuffix
        $AATarget = "$AATargetName@$AAUPNSuffix"

        # Create Resource Account
        if ($RADisplayName -ne "") {
            $LastRAUPN = $RAUPN
            $instance = New-CsOnlineApplicationInstance -UserPrincipalName $RAUPN -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $RADisplayName
        
            write-host "Created resource account: " $RADisplayName " " $RAUPN -foregroundcolor Green
            # The following two lines are not required as an application ID was provided at the creation of the application instance, you need not run this cmdlet.
            #write-host Syncing Resource Account from Azure Active directory
            #Sync-CsOnlineApplicationInstance -ObjectId $instance.ObjectID
        }
        
		# Create Auto Attendant
        if ($AADisplayName -ne "") {
			# Get Operator Information
			$operatorID = (Get-CsOnlineUser -Identity $AAOperatorName).Identity
			$operatorEntity = New-CsAutoAttendantCallableEntity -Identity $operatorID -Type $AAOperatorType
			
            #Create After Hours Schedules
			$timerangeMoFr = New-CsOnlineTimeRange -Start 08:30 -end 17:00
			$afterHoursSchedule = New-CsOnlineSchedule -Name "After Hours Schedule" -WeeklyRecurrentSchedule -MondayHours @($timerangeMoFr) -TuesdayHours @($timerangeMoFr) -WednesdayHours @($timerangeMoFr) -ThursdayHours @($timerangeMoFr) -FridayHours @($timerangeMoFr) -Complement
			# Create After Hours Prompts
			$afterHoursGreetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $AAAHGreetingTxt
			# Create After Hours Call Flow
			$AHMenuOptionTarget = (Get-AzureADGroup -SearchString $AAVoicemail).ObjectID
			$AHMenuOptionEntity = New-CsAutoAttendantCallableEntity -Identity $AHMenuOptionTarget -Type SharedVoicemail -EnableTranscription #-EnableSharedVoicemailSystemPromptSuppression
			$AHMenuOptionAA = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $AHMenuOptionEntity
			## Alternate option: $AHMenuOptionAA = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $AHmenuAAQ = New-CsAutoAttendantMenu -Name "After Hours Menu" -MenuOptions @($AHmenuOptionAA)
            $afterHoursCallFlow = New-CsAutoAttendantCallFlow -Name "After Hours Call Flow" -Greetings @($afterHoursGreetingPrompt) -Menu $AHmenuAAQ
			$afterHoursCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation -Type AfterHours -ScheduleId $afterHoursSchedule.Id -CallFlowId $afterHoursCallFlow.Id
			
			# Public Holiday Schedule
			$PHScheduleId = (Get-CsOnlineSchedule | Where-Object Name -eq $AAPublicHolidaysName).Id
			# Create Public Holidays Prompts
			$PHGreetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $AAPHGreetingTxt
			# Create Public Holidays Call Flow
            $PHMenuOptionTarget = (Get-AzureADGroup -SearchString $AAVoicemail).ObjectID
			$PHMenuOptionEntity = New-CsAutoAttendantCallableEntity -Identity $PHMenuOptionTarget -Type SharedVoicemail -EnableTranscription #-EnableSharedVoicemailSystemPromptSuppression
			$PHMenuOption = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $PHMenuOptionEntity
			
			#$PHMenuOptionAA = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $PHmenuAAQ = New-CsAutoAttendantMenu -Name "Public Holidays Menu" -MenuOptions @($PHmenuOption)
			$PublicHolidaysCallFlow = New-CsAutoAttendantCallFlow -Name "Public Holidays Call Flow" -Greetings @($PHGreetingPrompt) -Menu $PHmenuAAQ
			$PublicHolidaysCallHandlingAssociation = New-CsAutoAttendantCallHandlingAssociation -Type Holiday -ScheduleId $PHScheduleId -CallFlowId $PublicHolidaysCallFlow.Id
			
            #Create Main Call Flow
			#$AAGreetingPrompt = New-CsAutoAttendantPrompt -ActiveType 'None' -TextToSpeechPrompt $AAGreetingTxt
            $AAGreetingPrompt = New-CsAutoAttendantPrompt -TextToSpeechPrompt $AAGreetingTxt
			
			$MenuOptionTarget = (Get-CsOnlineUser -Identity $AATarget).Identity
			$MenuOptionEntity = New-CsAutoAttendantCallableEntity -Identity $MenuOptionTarget -Type applicationendpoint
			$MenuOptionAA = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $MenuOptionEntity
			
            #$MenuOptionAA = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $menuAAQ = New-CsAutoAttendantMenu -Name "$AADisplayName" -MenuOptions @($menuOptionAA)
            $callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Greetings @($AAGreetingPrompt) -Menu $menuAAQ
            New-CsAutoAttendant -Name $AADisplayName -Language $language -TimeZoneId $AATimeZone -DefaultCallFlow $callFlowAAQ -CallFlows @($afterHoursCallFlow,$PublicHolidaysCallFlow) -CallHandlingAssociations @($afterHoursCallHandlingAssociation,$PublicHolidaysCallHandlingAssociation) -Operator $operatorEntity
            write-host "Created Auto Attendant: " $AADisplayName " " -foregroundcolor Green
        }

    } 

#Pause for 2 minute cause cloud lag
Write-Host 2 minute wait cause cloud lag sucks!
Write-Host "Waiting 2 mins for Cloud sync before linking resource account(s) to AutoAttendant(s)"
Start-Sleep -s 120
#Pause until last Resource Account is showing
(Get-CsOnlineUser $LastRAUPN).ObjectId
if($? -ne 'false')
{
    while($? -ne 'false')
    {
        Write-Host "Resource Account not found waiting further 20 seconds"
        Start-Sleep -s 20
        (Get-CsOnlineUser $LastRAUPN).ObjectId
    }
}


#Link Resource account with AutoAttendant
### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    write-host "File import error"
    Break
}

    foreach ($user in $users)
    {
        $AADisplayName = $user.AADisplayName
        $AAName = $user.AAName
        $AATimeZone = $user.AATimeZone
        $RADisplayName = $user.AARADisplayName
        $RAUPNPrefix = $user.AARAUPNPrefix
        $UPNSuffix = $user.UPNSuffix
        $RAUPN = "$RAUPNPrefix@$UPNSuffix"

        if ($AAName -ne "") {
            $RAappinstanceid = (Get-CsOnlineUser $RAUPN).Identity
            $AAid = (Get-CsAutoAttendant -NameFilter $AAName | Where-Object Name -eq $AAName).Identity

            write-host "Assigning: " $RADisplayName "Resource account assigned to AA: " $AAName -foregroundcolor Green
            # Associate AutoAttendant and AA Resource account
            New-CsOnlineApplicationInstanceAssociation -Identities $RAappinstanceid -ConfigurationId $AAid -ConfigurationType AutoAttendant

            write-host $RADisplayName "Resource account assigned to AA: " $AAName -foregroundcolor Green
        }
	
    }


#License Resource account with Virtual User phone system license and set usage location to AU (Australia)
#
#Leaving the get license sku command and result here as handy to be aware of what you are search for in the where-objects used later on
#
#Get-MsolAccountSku | Select AccountSkuId,SkuPartNumber,ActiveUnits,ConsumedUnits
#Example
#AccountSkuId                            ActiveUnits WarningUnits ConsumedUnits
#------------                            ----------- ------------ -------------
#adgceau:MCOEV_TELSTRA                   198         0            16
#reseller-account:FLOW_FREE              10000       0            8            
#reseller-account:MCOCAP                 25          0            1            
#reseller-account:MCOPSTNEAU2            91          0            26           
#reseller-account:SPE_E5                 87          0            84           
#reseller-account:TEAMS_COMMERCIAL_TRIAL 500000      0            0            
#reseller-account:RIGHTSMANAGEMENT_ADHOC 10000       0            1            
#reseller-account:STANDARDPACK           20          0            17  
#   
#Alternatively use:
#Get-AzureADSubscribedSku | Select -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits | FT
# SkuId                                SkuPartNumber                                        ConsumedUnits  Enabled Suspended Warning
# -----                                -------------                                        -------------  ------- --------- -------
# e43b5b99-8dfb-405f-9987-dc307f34bcbd MCOEV                                                            1      165         0       0
# 440eaaa8-b3e0-484b-a8be-62870b9ba70a PHONESYSTEM_VIRTUALUSER                                         23       25         0       0
# 47794cd0-f0e5-45c5-9033-2eb6b5fc84e0 MCOPSTNC                                                         0 10000000         0       0
# de3312e1-c7b0-46e6-a7c3-a515ff90bc86 MCOPSTNEAU2                                                      0      159         0       0
# 05e9a617-0261-4cee-bb44-138d3ef5d965 SPE_E3 
# 0e142028-345e-45da-8d92-8bfd4093bbb9 PHONESYSTEM_VIRTUALUSER_FACULTY                                  1       40         0       0
# d979703c-028d-4de5-acbf-7955566b69b9 MCOEV_FACULTY                                                    0       37         0       0
#Finds the virtualusersku name this changes with different tenancies
#$virtualusersku = get-MsolAccountSku -TenantId $tenantID | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"} | select AccountSkuid
#$TCOSKU = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOPSTNEAU2" } | Select-Object AccountSkuid
$PhoneSystemVirtualUser = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
#$PhoneSystemVirtualUser.SkuId = "440eaaa8-b3e0-484b-a8be-62870b9ba70a"   # PHONESYSTEM_VIRTUALUSER
$PhoneSystemVirtualUser.SkuId = "0e142028-345e-45da-8d92-8bfd4093bbb9"   # PHONESYSTEM_VIRTUALUSER_FACULTY
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $PhoneSystemVirtualUser

# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date
#

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk Assign Phone System Resource Account License to Resource Accounts "
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
     write-host "Error importing .csv file: " $FileName -foregroundcolor Red
     Break
}
 
    foreach ($user in $users)
    {
        $AADisplayName = $user.AADisplayName
        $AAName = $user.AAName
        $AATimeZone = $user.AATimeZone
        $RADisplayName = $user.AARADisplayName
        $RAUPNPrefix = $user.AARAUPNPrefix
        $UPNSuffix = $user.UPNSuffix
        $RAUPN = "$RAUPNPrefix@$UPNSuffix"
        $AADisplayName = $user.AADisplayName
        $upn = $user.UPN
        $number = $user.Number
        $UsageLocation = $user.AARAUsageLocation
        $i = $i + 1
        $error.clear()

        if ($AAName -ne "") {
            write-host "$i. Processing:" $RAupn -foregroundcolor Yellow
            write-host "    Assigning Usage Location: " $UsageLocation -foregroundcolor Yellow -NoNewline
            Try {
              #Set users usage location to Australia as required by TCO365 Calling plan
              #Set-MsolUser -UserPrincipalName $upn -UsageLocation $UsageLocation -Verbose -ErrorAction SilentlyContinue
                 Set-AzureADUser -ObjectID $RAUPN -UsageLocation $UsageLocation
            }
            Catch {}
            if (!$error) {
                 #Start-Sleep -Milliseconds 2000
                 write-host "`r    Assigned Usage Location:  " $UsageLocation -foregroundcolor Green
            }
            else {
                 $errorcount = $errorcount + 1
                 write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
            }
            write-host "    Assigning Phone System Resouce Account License" -foregroundcolor Yellow -NoNewline
            Try {
                #Assign Phone System license to user
                #Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $phonesystemsku.AccountSkuId -Verbose -ErrorAction SilentlyContinue
                Set-AzureADUserLicense -ObjectId $RAUPN -AssignedLicenses $LicensesToAssign -Verbose -ErrorAction SilentlyContinue
            }
            Catch {}
            if (!$error) {
                #Start-Sleep -Milliseconds 2000
                write-host "`r    Assigned Phone System & TCO License to: " $RAUPN -foregroundcolor Green
            }
            else {
                $errorcount = $errorcount+1
                write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
            }
        }
     #
     $Prog = [int]($i / $linesInFile * 100)
     Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
     }

### Summary
# Calculate the Script Duration.
$FinishDate = get-Date
write-host ""; Write-Host "Completed processing"
$Interval = $FinishDate - $StartDate
"Script Duration: {0} HH:MM:SS" -f ($Interval.ToString())
write-host "Finish Time: " -NoNewline -foregroundcolor Yellow
write-host "$FinishDate" -ForegroundColor Cyan
write-host "Resource Accounts Processed: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
Write-Host ""


#    Disconnect-MicrosoftTeams

