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
#   
##########################################################
#Variables to be changed to suit each customer
##########################################################
$Filename = "C:\Temp\RemoveM365E5Users.csv"
#####################
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
$M365_E5_sku = get-MsolAccountSku | Where-Object { $_.skuPartNumber -contains "SPE_E5" } | Select-Object AccountSkuid

### Display Introduction ###
Write-host ""
Write-Progress -Activity "Script in Progress" -Status "$i% Complete:" -PercentComplete ($i / $linesInFile * 100)
Write-host ""
Write-Host "Bulk UN-Assign Licenses from users "
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
     $i = $i + 1
     $error.clear()
     write-host "$i. Processing:" $upn -foregroundcolor Yellow
     
     write-host "    Unassigning M365 E5 License" -foregroundcolor Yellow -NoNewline
     Try {
          #Assign Phone System license to user
          Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $M365_E5_sku.AccountSkuId -Verbose -ErrorAction SilentlyContinue
          }
     Catch {}
     if (!$error) {
          #Start-Sleep -Milliseconds 2000
          write-host "`r    Unassigned M365 E5 License " -foregroundcolor Green
          }
     else {
          $errorcount = $errorcount+1
          write-host 'Failed due to:' $Error[0].Exception.Message -ForegroundColor Red
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

