#14/06/2021 Andrew Baird
#V3 20/07/2021 Enhances by Stephen Bell - Added Intro, Progress, Summary
#V4 20/07/2021 Enhances by Stephen Bell - Added Duration and a little more bling
#Reach out if there are any issues or refinements needed

#Connect-MsolService

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
#
#Leaving the get license sku command and result here as handy to be aware of what you are search for in the where-objects used later on
#
#Get-MsolAccountSku | Select AccountSkuId,SkuPartNumber,ActiveUnits,ConsumedUnits
#Example
#AccountSkuId                            ActiveUnits WarningUnits ConsumedUnits
#------------                            ----------- ------------ -------------
#adgceau:MCOEV_TELSTRA             198         0            16
#reseller-account:FLOW_FREE              10000       0            8            
#reseller-account:MCOCAP                 25          0            1            
#reseller-account:MCOPSTNEAU2            91          0            26           
#reseller-account:SPE_E5                 87          0            84           
#reseller-account:TEAMS_COMMERCIAL_TRIAL 500000      0            0            
#reseller-account:RIGHTSMANAGEMENT_ADHOC 10000       0            1            
#reseller-account:STANDARDPACK           20          0            17  
<#TSHOPBIZ:VISIOCLIENT                        VISIOCLIENT                                 40            32
TSHOPBIZ:STREAM                             STREAM                                 1000000             4
TSHOPBIZ:EMSPREMIUM                         EMSPREMIUM                                  50             2
TSHOPBIZ:BUSINESS_VOICE_DIRECTROUTING       BUSINESS_VOICE_DIRECTROUTING                25             2
TSHOPBIZ:MCOEV_TELSTRA                      MCOEV_TELSTRA                                1             1
TSHOPBIZ:POWER_BI_PRO                       POWER_BI_PRO                               100            22
TSHOPBIZ:WIN_ENT_E5                         WIN_ENT_E5                                 150             2
TSHOPBIZ:WINDOWS_STORE                      WINDOWS_STORE                               25             0
TSHOPBIZ:PROJECTESSENTIALS                  PROJECTESSENTIALS                           20             1
TSHOPBIZ:DESKLESSPACK                       DESKLESSPACK                                 1             0
TSHOPBIZ:FLOW_FREE                          FLOW_FREE                                10000            86
TSHOPBIZ:PROJECTPREMIUM                     PROJECTPREMIUM                              40            16
TSHOPBIZ:PHONESYSTEM_VIRTUALUSER            PHONESYSTEM_VIRTUALUSER                     65            59
TSHOPBIZ:CCIBOTS_PRIVPREV_VIRAL             CCIBOTS_PRIVPREV_VIRAL                   10000             0
TSHOPBIZ:FORMS_PRO                          FORMS_PRO                              1000000             0
TSHOPBIZ:POWERAPPS_VIRAL                    POWERAPPS_VIRAL                          10000             2
TSHOPBIZ:MCOCAP                             MCOCAP                                       1             1
TSHOPBIZ:MEETING_ROOM                       MEETING_ROOM                                16            16
TSHOPBIZ:POWER_BI_STANDARD                  POWER_BI_STANDARD                      1000000             7
TSHOPBIZ:MCOPSTNC                           MCOPSTNC                              10000000             3
TSHOPBIZ:VISIO_PLAN2_DEPT                   VISIO_PLAN2_DEPT                             0             0
TSHOPBIZ:TEST_M365_LIGHTHOUSE_PARTNER_PLAN1 TEST_M365_LIGHTHOUSE_PARTNER_PLAN1           1             0
TSHOPBIZ:ENTERPRISEPREMIUM_NOPSTNCONF       ENTERPRISEPREMIUM_NOPSTNCONF               100            16
TSHOPBIZ:MCOPSTNEAU2                        MCOPSTNEAU2                                110           110
TSHOPBIZ:ADALLOM_STANDALONE                 ADALLOM_STANDALONE                          50             0
TSHOPBIZ:SPE_E5                             SPE_E5                                     125           125
TSHOPBIZ:EMS                                EMS                                        100             0
TSHOPBIZ:SMB_APPS                           SMB_APPS                                    12             4
TSHOPBIZ:MCOMEETADV                         MCOMEETADV                                 200             0
TSHOPBIZ:RMSBASIC                           RMSBASIC                                     1             0
TSHOPBIZ:SPE_E3                             SPE_E3                                     200            57
TSHOPBIZ:PROJECTPROFESSIONAL                PROJECTPROFESSIONAL                         54             0
TSHOPBIZ:PROJECT_MADEIRA_PREVIEW_IW_SKU     PROJECT_MADEIRA_PREVIEW_IW_SKU           10000             2
TSHOPBIZ:VISIO_PLAN1_DEPT                   VISIO_PLAN1_DEPT                             0             0
TSHOPBIZ:STANDARDPACK                       STANDARDPACK                                 1             0
#>   
##########################################################
#Variables to be changed to suit each customer
#$path = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\PROTECTOR ALUMINIUM PTY LTD\PR2492-TCO\Project Templates\NumberAssignments.csv"
#$File = "NumberAssignments.csv"

##########################################################
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\PROTECTOR ALUMINIUM PTY LTD\PR2492-TCO\Project Templates\NumberAssignments.csv"
#
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
$phonesystemsku = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOEV" } | Select-Object AccountSkuid
$TCOSKU = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "MCOPSTNEAU2" } | Select-Object AccountSkuid

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
     Break
}
 
### Process all users in .csv file ###
foreach ($user in $users) {
     $upn = $user.UPN
     $number = $user.Number
     $i = $i + 1
     $error.clear()
     write-host "$i. Processing:" $upn -foregroundcolor Yellow
     write-host "    Assigning Usage Location: AU" -foregroundcolor Yellow -NoNewline
     Try {
          #Set users usage location to Australia as required by TCO365 Calling plan
          Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU" -Verbose -ErrorAction SilentlyContinue
     }
     Catch {}
     if (!$error) {
          #Start-Sleep -Milliseconds 2000
          write-host "`r    Assigned Usage Location: AU " -foregroundcolor Green
     }
     else {
          $errorcount = $errorcount + 1
          write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
     }
            write-host "    Assigning Phone System License" -foregroundcolor Yellow -NoNewline
            Try {
                 #Assign Phone System license to user
                 Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $phonesystemsku.AccountSkuId -Verbose -ErrorAction SilentlyContinue
                 }
            Catch {}
            if (!$error) {
                 #Start-Sleep -Milliseconds 2000
                 write-host "`r    Assigned Phone System License " -foregroundcolor Green
                 }
            else {
                 $errorcount = $errorcount+1
                 write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
                 }
     write-host "    Assigning" $upn "TCO365 Calling plan" -foregroundcolor Yellow -NoNewline
     Try {
          #Assign Telstra Calling Plan to user
          Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $TCOSKU.AccountSkuId -Verbose -ErrorAction SilentlyContinue
     }
     Catch {}
     if (!$error) {
          #Start-Sleep -Milliseconds 2000
          write-host "`r    Assigned TCO365 Calling Plan " -foregroundcolor Green
     }
     else {
          $errorcount = $errorcount + 1
          write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor Red
     }
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

#Get-PSSession | Remove-PSSession

