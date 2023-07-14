# Filename: BulkProcessTCOUsersV5.ps1
#
# 14/06/2021 Andrew Baird
# V4 23/07/2021 Enhances by Stephen Bell
# V5 22/05/2022 Combine multiple User assignment processors with latest enhancements
# V6 08/05/2023 Added some handling of EDU/NFP licensing
#
# Please Reach out if there are any issues or refinements needed

##########################################################
#
# Variables to be changed to suit each customer
#
##########################################################
write-host "Preparing..."
Write-host ""
$Filename = "C:\Users\StephenBell\Entag Group\Projects - Customer Projects\ALLEN'S TRAINING PTY LTD\LD26214 - TCO + TID\PR2857 - TCO365\Project Templates\UserAssignmentList.csv"
$TenantID = "7decc850-54f1-40bf-ada5-ed61fcf59721"
#Connect-MicrosoftTeams -TenantId $TenantID #Customers Tenant ID
#Connect-AzureAD -TenantID $TenantID
####Connect-MsolService  #Connect to Entag but use -TenantID switch to execute commands against customer tenany ID
#Connect-PartnerCenter #Sign in as ENTAG Partner Portal admin
$TenantInfo = Get-PartnerCustomer -CustomerId $TenantID
$language = "en-AU"
#
#########################################

write-host "Tenant Name: " $TenantInfo.Name "  Tenant Domain: " $TenantInfo.Domain "  Tenant ID: " $TenantInfo.CustomerID
$confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]: "
while($confirmation1 -ne "y")
{
    if ($confirmation1 -eq 'n') {break}
    $confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]: "
}

$confirmation2 = Read-Host "Are you happy with this file location for the CSV? " $Filename " [y/n]: "
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV? " $Filename " [y/n]: "
}
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
### End Functions ###

<# region   [System.Enum]::GetValues('ConsoleColor') | ForEach-Object { Write-Host $_ -ForegroundColor $_ }

#Show-Colors #>

read-host “Checking all user object UPN's exist before processing assignments, press Enter to continue or Ctrl-C to exit”

#############################################################################################################
#
# Check all user object UPN's exist before processing assignments
#
#############################################################################################################

#Filename is the csv with user list heading UPN
#Heading UPN and Number and CallerID are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =
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
    write-host "Error importing .csv file: " $FileName -foregroundcolor Red
    Break
}

### Process all users in .csv file ###
ForEach ($user in $users) {
    $upn = $user.UPN
    $number = $user.Number
    $i = $i + 1
    $error.clear()
    write-host "$i. Checking user:" $upn $number $callerid "" -foregroundcolor Yellow -NoNewline
    Try {
        #Set users Voice Routing Policy to $Null which is Global default policy
        #Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null -Verbose      
        #Assign user a telephone number
        #Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number -Verbose
        #Grant-CsCallingLineIdentity -Identity $upn -PolicyName $callerid -verbose
        #$userdetails = Get-CsOnlineUser -TenantId $tenantID -identity $upn | Select DisplayName,UserPrincipalName -verbose
        $userdetails = Get-AzureADUser -ObjectID $upn | Select DisplayName, UserPrincipalName, UsageLocation
        #$userdetails = Get-MsolUser -UserPrincipalName $upn
        #$userdetails = Get-MsolUser -TenantId $tenantID -UserPrincipalName $upn
    }
    Catch {}
    if (!$error) {
        Start-Sleep -Milliseconds 2000
        write-host "`r$i. Checked user:" $upn $number $callerid $userdetails.UsageLocation " " -foregroundcolor Green
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
#Get-MsolAccountSku
Get-AzureADSubscribedSku

read-host "Press ENTER to continue...Bulk Assign Phone System & TCO Licenses to users"

#############################################################################################################
#
# Bulk Assign Phone System & TCO Licenses to users
#
#############################################################################################################
#
#Leaving the get license sku command and result here as handy to be aware of what you are search for in the where-objects used later on. Check if cheap CFP/EDU licenses used
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
# 05e9a617-0261-4cee-bb44-138d3ef5d965 SPE_E3                                                         860      860         0       0
# 0e142028-345e-45da-8d92-8bfd4093bbb9 PHONESYSTEM_VIRTUALUSER_FACULTY                                  1       40         0       0
# d979703c-028d-4de5-acbf-7955566b69b9 MCOEV_FACULTY                                                    0       37         0       0

#$VerbosePreference =
# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date
#

#$Credentials = Get-Credential
#Connect-MsolService
# -Credential $credentials

#Add the SKU id you want to add license for
#If you have issues with contain you can replace with -like if needed
#$phonesystemsku = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOEV" } | Select-Object AccountSkuid
#$TCOSKU = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOPSTNEAU2" } | Select-Object AccountSkuid
$MCOEV = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
$MCOPSTNEAU2 = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
#$MCOEV.SkuId = "e43b5b99-8dfb-405f-9987-dc307f34bcbd"  # MCOEV
$MCOEV.SkuId = "d979703c-028d-4de5-acbf-7955566b69b9"  # MCOEV_FACULTY 
$MCOPSTNEAU2.SkuId = "de3312e1-c7b0-46e6-a7c3-a515ff90bc86"
$LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
$LicensesToAssign.AddLicenses = $MCOEV,$MCOPSTNEAU2    # Use this line if both licenses required
#$LicensesToAssign.AddLicenses = $MCOPSTNEAU2   # Use this line if just a call plan is required

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk Assign Licenses to users "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total Users to process: " -NoNewline -ForegroundColor Yellow
Write-Host "$LinesInFile" -foregroundcolor Cyan
write-host "=========================================" -foregroundcolor Yellow

#Command doesn't like the combined license variable so had to remove and add a seperate line in the for each loop
#$Combinedlicense = $TCOSKU.AccountSkuId + "," + $phonesystemsku.AccountSkuId
#Filename is the csv with user list heading UPN

### Import .csv file
Try {
     $users = Import-Csv $FileName
}
Catch {
     write-host "Error importing .csv file: " $FileName -foregroundcolor Red
     Break
}
 
### Process all users in .csv file ###
foreach ($user in $users) {
     $upn = $user.UPN
     $number = $user.Number
     $UsageLocation = $user.UsageLocation
     $i = $i + 1
     $error.clear()
     write-host "$i. Processing:" $upn -foregroundcolor Yellow
     write-host "    Assigning Usage Location: " $UsageLocation -foregroundcolor Yellow -NoNewline
     Try {
          #Set users usage location to Australia as required by TCO365 Calling plan
          #Set-MsolUser -UserPrincipalName $upn -UsageLocation $UsageLocation -Verbose -ErrorAction SilentlyContinue
          Set-AzureADUser -ObjectID $upn -UsageLocation $UsageLocation
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
     write-host "    Assigning Phone System & TCO License" -foregroundcolor Yellow -NoNewline
     Try {
         #Assign Phone System license to user
         #Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $phonesystemsku.AccountSkuId -Verbose -ErrorAction SilentlyContinue
         Set-AzureADUserLicense -ObjectId $upn -AssignedLicenses $LicensesToAssign -Verbose -ErrorAction SilentlyContinue
         }
     Catch {}
     if (!$error) {
         #Start-Sleep -Milliseconds 2000
         write-host "`r    Assigned Phone System & TCO License " -foregroundcolor Green
         }
     else {
         $errorcount = $errorcount+1
         write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
         }
#     write-host "    Assigning" $upn "TCO365 Calling plan" -foregroundcolor Yellow -NoNewline
#     Try {
#          #Assign Telstra Calling Plan to user
#          Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $TCOSKU.AccountSkuId -Verbose -ErrorAction SilentlyContinue
#     }
#     Catch {}
#     if (!$error) {
#          #Start-Sleep -Milliseconds 2000
#          write-host "`r    Assigned TCO365 Calling Plan " -foregroundcolor Green
#     }
#     else {
#          $errorcount = $errorcount + 1
#          write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
#     }
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
write-host "Users Processed: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
Write-Host ""

Start-Sleep -Milliseconds 120000
Write-Host ""
read-host “Press ENTER to continue...Bulk Assign numbers to users”

#############################################################################################################
#
# Bulk Assign numbers to users
#
#############################################################################################################
#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
#$VerbosePreference =

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
Write-Host "Bulk Assign numbers to users "
write-host "============================" -foregroundcolor Yellow
write-host "Start Time: " -NoNewline -foregroundcolor Yellow
write-host "$StartDate" -ForegroundColor Cyan
write-host "Importing file: " -NoNewline -foregroundcolor Yellow
write-host "$Filename" -ForegroundColor Cyan
Write-host "Total phonenumber assignments to process: " -NoNewline -ForegroundColor Yellow
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

### Process all users in .csv file ###
ForEach ($user in $users) {
    $upn = $user.UPN
    $number = $user.Number
    $i = $i + 1
    $error.clear()
    write-host "$i. Assigning" $upn $number "" -foregroundcolor Yellow -NoNewline
    Try {
        #Set users Voice Routing Policy to $Null which is Global default policy
        Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null #-Verbose
        #Next two lines for Direct Route Teams users      
        #Set-CsUser -Identity $UPN -OnPremLineURI $Null
        #Set-CsUser -Identity $UPN -OnPremLineURI TEL:$number
        #Assign Teams Call Plan user a telephone number
        #Get-CsOnlineUser -Identity $UPN | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
        
        Set-CsPhoneNumberAssignment -Identity $upn -PhoneNumber $number -PhoneNumberType CallingPlan #-verbose
    }
    Catch {}
    if (!$error) {
        #Start-Sleep -Milliseconds 2000
        write-host "`r$i. Assigned" $upn $number " " -foregroundcolor Green
    }
    else {
        $errorcount = $errorcount + 1
        write-host "`r$i. # Assigning Error" $upn $number " " -foregroundcolor Red
        read-host “Press ENTER to continue: "
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
write-host "Numbers Assigned: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""
Write-Host ""


read-host “Press ENTER to continue...Bulk Assign Caller-ID policy to users”

#############################################################################################################
#
# Bulk Assign Caller-ID policy to users
#
#############################################################################################################
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
            write-host "`r$i. CallerID Assigning Error" $upn $number " " -foregroundcolor Red
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