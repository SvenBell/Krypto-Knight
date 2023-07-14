﻿#9/7/23 Stephen Bell
# imports a .csv file of UPN/Alias/EmailAddress's to check if a correspinding ExchangeOnline Mailbox exisits and reports accordingly
#v6 Added Option of MSOline/AzureAD/CS
#Reach out if there are any issues or refinements needed

### Functions ###
###
### End Functions ###

#Connect-MicrosoftTeams

##########################################################
#
# Variables to be changed to suit each customer
#
##########################################################
write-host "Preparing..."
Write-host ""
#Filename is the csv with user list heading UPN
$Filename = "C:\temp\PCYC-HRv3.csv"
#$TenantID = "7decc850-54f1-40bf-ada5-ed61fcf59721"
#Connect-MicrosoftTeams -TenantId $TenantID #Customers Tenant ID
#Connect-AzureAD -TenantID $TenantID
Connect-MsolService  #Connect to Entag but use -TenantID switch to execute commands against customer tenany ID
Connect-ExchangeOnline
#Connect-PartnerCenter #Sign in as ENTAG Partner Portal admin
#$TenantInfo = Get-PartnerCustomer -CustomerId $TenantID
#$language = "en-AU"
#
#########################################

#write-host "Tenant Name: " $TenantInfo.Name "  Tenant Domain: " $TenantInfo.Domain "  Tenant ID: " $TenantInfo.CustomerID
#$confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]: "
#while($confirmation1 -ne "y")
#{
#    if ($confirmation1 -eq 'n') {break}
#    $confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]: "
#}

$confirmation2 = Read-Host "Are you happy with this file location for the CSV? " $Filename " [y/n]: "
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV? " $Filename " [y/n]: "
}

# Establish Progress variables
$fileStats = Get-Content $Filename | Measure-Object -line
$linesInFile = $fileStats.Lines - 1
$errorcount = 0
$i = 0
$Prog = 0
$StartDate = get-Date


read-host “Checking all user object UPN's exist, press Enter to continue or Ctrl-C to exit”

#############################################################################################################
#
# Check all user object UPN's exist 
#
#############################################################################################################

#Filename is the csv with user list heading UPN
#File Heading: UPN  is needed.   Also check code below for other expected input columns
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
Write-host "Total userto validate to process: " -NoNewline -ForegroundColor Yellow
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
    $i = $i + 1
    $error.clear()
    write-host "$i. Checking user:" $upn "" -foregroundcolor Yellow -NoNewline
    Try {
        #Set users Voice Routing Policy to $Null which is Global default policy
        #Grant-CsOnlineVoiceRoutingPolicy -Identity $UPN -PolicyName $Null -Verbose      
        
        #$userdetails = Get-CsOnlineUser -Identity $upn | Select DisplayName, UserPrincipalName
        #$userdetails = Get-AzureADUser -ObjectID $upn | Select DisplayName, UserPrincipalName, UsageLocation
        #$AZuserdetails = Get-AzureADUser -ObjectID $upn | Select DisplayName, UserPrincipalName, UsageLocation
        $EXOuserdetails = Get-EXOMailbox -Identity $upn | Select DisplayName, UserPrincipalName, PrimarySmtpAddress, RecipientType, Totalitemsize -ErrorAction SilentlyContinue
        #$userdetails = Get-MsolUser -UserPrincipalName $upn
        #$userdetails = Get-MsolUser -TenantId $tenantID -UserPrincipalName $upn
    }
    Catch {}
    if (!$error) {
        #Start-Sleep -Milliseconds 2000
        write-host "`r$i. Checked user:" $upn $EXOuserdetails.UserPrincipalName $EXOuserdetails.DisplayName " " -foregroundcolor Green
        $stats = Get-EXOMailboxStatistics $EXOuserdetails.UserPrincipalName -ErrorAction SilentlyContinue
        $MSOLAccount = get-msoluser -UserPrincipalName $EXOuserdetails.UserPrincipalName -ErrorAction SilentlyContinue
        $ExportObject = [PSCustomObject]@{
            HREmail = $user.UPN
            UserPrincipalName = $EXOuserdetails.UserPrincipalName
            PrimarySmtpAddress = $EXOuserdetails.PrimarySmtpAddress
            Mailboxsize = $stats.Totalitemsize
            DisplayName = $EXOuserdetails.DisplayName
            RecipientType = $EXOuserdetails.RecipientType
            LicensesAssigned = $MSOLAccount.Licenses.accountskuid -join ';'
            IDNumber = $user.IdNumber
            GivenName = $user.GivenName
            FamilyName = $user.FamilyName
            PositionTitle = $user.PositionTitle
            JobTitle = $user.JobTitle
            EmployeeClass = $user.EmployeeClass
            ProposedLicenseType1 = $user.ProposedLicenseType1
            ProposedLicenseType2 = $user.ProposedLicenseType2 
            }
    }
    else {
        $errorcount = $errorcount + 1
        write-host "`r$i. Error user:" $upn  " " -foregroundcolor Red
        $ExportObject = [PSCustomObject]@{
            HREmail = $user.UPN
            UserPrincipalName = "ERROR"
            PrimarySmtpAddress = "ERROR"
            Mailboxsize = "ERROR"
            DisplayName = "ERROR"
            RecipientType = "ERROR"
            LicensesAssigned = "ERROR"
            IDNumber = $user.IdNumber
            GivenName = $user.GivenName
            FamilyName = $user.FamilyName
            PositionTitle = $user.PositionTitle
            JobTitle = $user.JobTitle
            EmployeeClass = $user.EmployeeClass
            ProposedLicenseType1 = $user.ProposedLicenseType1
            ProposedLicenseType2 = $user.ProposedLicenseType2 
            }
    }
    $Prog = [int]($i / $linesInFile * 100)
    Write-Progress -Activity "Script in Progress" -Status "$Prog% Complete:" -PercentComplete ($i / $linesInFile * 100)
    $ExportObject | export-csv PCYC-EXOUPNCheckReportv5.csv -NoClobber -NoTypeInformation -Append
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
write-host "Users validated: "($linesInFile - $errorcount)"of"$linesInFile -ForegroundColor Green
write-host "Number of Errors: " $errorcount -ForegroundColor Red
Write-Host ""


#    Remove-PSSession