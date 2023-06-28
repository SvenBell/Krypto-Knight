﻿#Bulk create and Setup: CQs & Resource Accounts
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
#Connect-MsolService
#Connect-PartnerCenter

#Customise for each customer
########################################
#$domain= "fkgardnersons.onmicrosoft.com"
write-host "Preparing..."
Write-host ""
$Filename = "C:\Users\stephen.bell\Entag Group\Projects - Customer Projects\IOR ENERGY PTY LTD\PR2560-TCO\Project Templates\BulkAACQ.csv"
$TenantID = "e246235b-d301-41f8-b9dd-756c6ac9b294"
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

$confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename
}


### Import .csv file
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
Write-Host "Bulk create CQs and Resource Accounts "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total CQ Resource accounts to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$CQsTotal" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

######################################

#Create CQs and Resource accounts
    foreach ($user in $users) {
        $CQDisplayName = $user.CQDisplayName
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
        $CQAlertTime = $user.CQAlertTime
        $CQTimeout = $user.CQTimeout
        If ($user.CQConferenceMode -eq "On") {
            $CQConferenceMode = $true
        }
        Else {
            $CQConferenceMode = $false
        }
        #read-host “Press ENTER to continue...”
        $i = $i + 1
        $error.clear()
        if ($CQDisplayName -ne "") {
            #$LastCQUPN = $CQUPN
            #Create Call Queue
            write-host "$i. Creating CQ: " $CQDisplayName -foregroundcolor Yellow
            Try {
                New-CsCallQueue -Name $CQDisplayName -RoutingMethod $CQRoutingMethod -AllowOptOut $CQAllowOptOut -AgentAlertTime $CQAlertTime -TimeoutThreshold $CQTimeout -UseDefaultMusicOnHold $true -LanguageId $language -ConferenceMode $CQConferenceMode
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
        if ($CQRAName -ne "") {
            #Create Call Queue Resource Account
            $LastCQRAUPN = $CQRAUPN
            write-host "$i. Creating CQ resource account: " $CQRAUPN -foregroundcolor Yellow
            Try {
                New-CsOnlineApplicationInstance -UserPrincipalName $CQRAUPN -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQRAName
            }
            Catch {}
            if (!$error) {
                write-host "`r$i. Created CQ resource account: " $CQRAUPN -foregroundcolor Green
            }
            else {
                $errorcount = $errorcount + 1
                write-host $error
                read-host “Press ENTER to continue...”
            }
            $Prog = [int]($i / $linesInFile * 100)
            Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
        }
    } 

#######################################
#Wait 2 mins then check if Resource Account showing yet. If not yet showing wait 20s and check again until it does show
#Pause for 2 minute cause cloud lag
Write-Host
Write-Host 2 minute 30 sec wait cause cloud lag sucks!
Write-Host Resource Account Stage
Start-Sleep -s 150

#Pause until last Resource Account is showing
(Get-CsOnlineUser $LastCQRAUPN).ObjectId
if($? -ne 'false') {
    while($? -ne 'false') {
        Write-Host "Resource Account not found waiting further 20 seconds"
        Start-Sleep -s 20
        (Get-CsOnlineUser $LastCQRAUPN).ObjectId
    }
}
Write-Host
######################################
### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    Break
}

#Associate Call Queues and CQ Resource accounts
    $i = 0
    $Prog = 0
    foreach ($user in $users) {
            $CQDisplayName = $user.CQDisplayName
            $CQName = $user.CQName
            $CQRAName = $user.CQRAName
            $CQUPNSuffix = $user.UPNSuffix
            $CQRAUPN = "$CQRAName@$CQUPNSuffix"
            $CQRoutingMethod = $user.CQRoutingMethod
            $CQAllowOptOut = $user.CQAllowOptOut
            if ($CQAllowOptOut -eq "On") {$CQAllowOptOut = $true}
            Else {$CQAllowOptOut = $false}
            $CQAlertTime = $user.CQAlertTime
            $CQTimeout = $user.CQTimeout
            $CQConferenceMode = $user.CQConferenceMode
        


            $i = $i + 1
            $error.clear()
        if ($CQName -ne "") {
            Try {
                $CQappinstanceid = (Get-CsOnlineUser $CQRAUPN).Identity
            }
            Catch {
                write-host $error
                read-host “Press ENTER to continue...”
            }
            Try {
                $CQid = (Get-CsCallQueue -NameFilter $CQName | Where-Object Name -eq $CQName).Identity
            }
            Catch {
                write-host $error
                read-host “Press ENTER to continue...”
            }
            write-host "Assigning CQ: " $CQName " to Resource account: " $CQRAUPN -foregroundcolor Yellow
            #Associate Call Queue and CQ Resource account
            Try {
                New-CsOnlineApplicationInstanceAssociation -Identities $CQappinstanceid -ConfigurationId $CQid -ConfigurationType CallQueue
            }
            Catch {}
            If (!$error) {
                write-host "`rAssigned CQ: " $CQName " to Resource account: " $CQUPN -foregroundcolor Green
            }
            else {
                $errorcount = $errorcount + 1
                write-host $error
                read-host “Press ENTER to continue...”
            }
            $Prog = [int]($i / $linesInFile * 100)
            Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
            $PSVULicensesRequired = $i
        }
    }

##################################
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
#Finds the virtualusersku name this changes with different tenancies
#$virtualusersku = get-MsolAccountSku -TenantId $tenantID | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"} | select AccountSkuid
#$TCOSKU = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOPSTNEAU2" } | Select-Object AccountSkuid
$PhoneSystemVirtualUser = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$PhoneSystemVirtualUser.SkuId = "440eaaa8-b3e0-484b-a8be-62870b9ba70a"
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $PhoneSystemVirtualUser

#Finds the virtualusersku name this changes with different tenancies
#Try {
#    $virtualusersku = get-MsolAccountSku -TenantId $tenantID | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"} | select AccountSkuid
#}
#Catch {
#    Break
#}
#$VirtualUserQtyAvail = get-MsolAccountSku -TenantId $tenantID | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"}
#Write-host ""
#Write-host "Phone System Virtual User licenses Available: " ($VirtualUserQtyAvail.ActiveUnits - $VirtualUserQtyAvail.ConsumedUnits) -foregroundcolor Yellow
#Write-host "Phone System Virtual User licenses required:  " $PSVULicensesRequired -foregroundcolor Yellow
#if (($VirtualUserQtyAvail.ActiveUnits - $VirtualUserQtyAvail.ConsumedUnits) -lt $PSVULicensesRequired) {
#    write-host "WARNING: "  -foregroundcolor Red 
#    write-host "`rInsufficient Phone System Virtual user licenses. Please acquire more before continueing..."  -foregroundcolor White
#    read-host “Press ENTER to continue...”
#}
#Else {}
#Write-host "Assigning Phone System Virtual User licenses..."  -foregroundcolor Green

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

#Assign Virtual User license to all Resoruce accounts
    $i = 0
    $Prog = 0
    foreach ($user in $users) {
        $CQDisplayName = $user.CQDisplayName
        $CQName = $user.CQName
        $CQRAName = $user.CQRAName
        $CQRAUPNSuffix = $user.UPNSuffix
        $CQRAUPN = "$CQRAName@$CQRAUPNSuffix"
        $UsageLocation = $user.CQRAUsageLocation
        $i = $i + 1
        $error.clear()
        if ($CQRAName -ne "") {
            write-host "$i. Processing:" $upn -foregroundcolor Yellow
            write-host "    Assigning Usage Location: " $UsageLocation -foregroundcolor Yellow -NoNewline
            Try {
              #Set users usage location to Australia as required by TCO365 Calling plan
              #Set-MsolUser -UserPrincipalName $upn -UsageLocation $UsageLocation -Verbose -ErrorAction SilentlyContinue
                 Set-AzureADUser -ObjectID $CQRAUPN -UsageLocation $UsageLocation
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
                Set-AzureADUserLicense -ObjectId $CQRAUPN -AssignedLicenses $LicensesToAssign -Verbose -ErrorAction SilentlyContinue
            }
            Catch {}
            if (!$error) {
                #Start-Sleep -Milliseconds 2000
                write-host "`r    Assigned Phone System Resource Account License " -foregroundcolor Green
            }
            else {
                $errorcount = $errorcount+1
                write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
            }
        #
        $Prog = [int]($i / $linesInFile * 100)
        Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
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
write-host "CQ Resource accounts created: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
Write-Host ""

#    Remove-PSSession $sfboSession
