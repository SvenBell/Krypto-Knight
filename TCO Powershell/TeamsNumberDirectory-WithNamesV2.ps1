﻿
<#PSScriptInfo

.VERSION 2.0

.GUID be53af09-7831-40cc-92a2-0a72b3fa7c1b

.AUTHOR Vikas Sukhija

.COMPANYNAME Techwizard.cloud

.COPYRIGHT Techwizard.cloud

.TAGS

.LICENSEURI https://techwizard.cloud/2021/05/31/available-team-numbers-report/

.PROJECTURI https://techwizard.cloud/2021/05/31/available-team-numbers-report/

.ICONURI

.EXTERNALMODULEDEPENDENCIES MicrosoftTeams 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
https://techwizard.cloud/2021/05/31/available-team-numbers-report/

.PRIVATEDATA

#>

#Requires -Module MicrosoftTeams

<# 

.DESCRIPTION 
 This will report the available phone numbers in Microsoft Teams 

#>
param (
  [string]$smtpserver,
  [string]$erroremail,
  [string]$from
 )
###################Functions############################
function New-FolderCreation
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]$foldername
  )
	

  $logpath  = (Get-Location).path + "\" + "$foldername" 
  $testlogpath = Test-Path -Path $logpath
  if($testlogpath -eq $false)
  {
    #Start-ProgressBar -Title "Creating $foldername folder" -Timer 10
    $null = New-Item -Path (Get-Location).path -Name $foldername -Type directory
  }
}
function Write-Log
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true,ParameterSetName = 'Create')]
    [array]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = 'Create')]
    [string]$Ext,
    [Parameter(Mandatory = $true,ParameterSetName = 'Create')]
    [string]$folder,
    
    [Parameter(ParameterSetName = 'Create',Position = 0)][switch]$Create,
    
    [Parameter(Mandatory = $true,ParameterSetName = 'Message')]
    [String]$message,
    [Parameter(Mandatory = $true,ParameterSetName = 'Message')]
    [String]$path,
    [Parameter(Mandatory = $false,ParameterSetName = 'Message')]
    [ValidateSet('Information','Warning','Error')]
    [string]$Severity = 'Information',
    
    [Parameter(ParameterSetName = 'Message',Position = 0)][Switch]$MSG
  )
  switch ($PsCmdlet.ParameterSetName) {
    "Create"
    {
      $log = @()
      $date1 = Get-Date -Format d
      $date1 = $date1.ToString().Replace("/", "-")
      $time = Get-Date -Format t
	
      $time = $time.ToString().Replace(":", "-")
      $time = $time.ToString().Replace(" ", "")
      New-FolderCreation -foldername $folder
      foreach ($n in $Name)
      {$log += (Get-Location).Path + "\" + $folder + "\" + $n + "_" + $date1 + "_" + $time + "_.$Ext"}
      return $log
    }
    "Message"
    {
      $date = Get-Date
      $concatmessage = "|$date" + "|   |" + $message +"|  |" + "$Severity|"
      switch($Severity){
        "Information"{Write-Host -Object $concatmessage -ForegroundColor Green}
        "Warning"{Write-Host -Object $concatmessage -ForegroundColor Yellow}
        "Error"{Write-Host -Object $concatmessage -ForegroundColor Red}
      }
      
      Add-Content -Path $path -Value $concatmessage
    }
  }
} #Function Write-Log
#####################logs and reports###################
$log = Write-Log -Name "AvailableTeamNumbersReport-Log" -folder "logs" -Ext "log"
$Report1 = Write-Log -Name "AvailableTeamNumbersReport-Report" -folder "Report" -Ext "csv"
$collection = @()

######connect to Skob and import modules ###################################
Write-Log -message "Start..................Script" -path $log
#try 
#{
#  Connect-MicrosoftTeams
#  Write-Log -Message "Connected to Teams module" -path $log
#}
#catch 
#{
#  $exception = $($_.Exception.Message)
#  Write-Log -Message "$exception" -path $log -Severity Error
#  Write-Log -Message "Exception has occured in connecting to Teams module" -path $log  -Severity Error
#  Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error occured in connecting to Teams module - AvailableTeamNumbersReport" -Body $($_.Exception.Message)
#  Exit;
#}
##################start processing users##################

try
{
  $allnumbers =Get-CsPhoneNumberAssignment -Top 100000 | Select TelephoneNumber,PstnPartnerName,NumberType,ActivationState,City,IsoCountryCode,IsoSubdivision,PortInOrderStatus,PstnAssignmentStatus,Capability
  Write-Log -message "Fetched Phonenumbers $($allnumbers.count) from Teams" -path $log
  $allassignednumbers = $allnumbers  | where{$_.PstnAssignmentStatus -ne 'Unassigned'}
  Write-Log -message "Fetched Assigned Phonenumbers $($allassignednumbers.count) from Teams" -path $log
  $allunassignednumbers = $allnumbers  | where{$_.PstnAssignmentStatus -eq 'Unassigned'}
  Write-Log -message "Fetched unAssigned Phonenumbers $($allunassignednumbers.count) from Teams" -path $log
  $getllcsonlineusernumbers = Get-CsOnlineUser -Filter {LineURI -ne $null} | Select UserPrincipalName, LineURI, DisplayName
  Write-Log -message "Fetched all assigned users $($getllcsonlineusernumbers.count) from Teams" -path $log
  ############## adding as error is not geting reported and less numbers are fetched#############
  if($($allnumbers.count) -lt "8000"){
    write-host "Line 154" -ForegroundColor Red
#    Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error occured getting details from TEAMS AvailableTeamNumbersReport" -Body "Error occured getting details from TEAMS AvailableTeamNumbersReport"
#    exit
  }
}
catch
{
  $exception = $($_.Exception.Message)
  Write-Log -Message "$exception" -path $log -Severity Error
  Write-Log -Message "Exception has occured getting details from TEAMS" -path $log  -Severity Error
  write-host "Line 164" -ForegroundColor Red
#  Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Error occured getting details from TEAMS AvailableTeamNumbersReport" -Body $($_.Exception.Message)
  Exit;
}

##########Export to Report#################################
Write-Log -Message "Start exporting Report" -path $log
[System.Collections.ArrayList]$collection = @()
ForEach($voicenumber in $allnumbers) 
{
  $mcoll = "" | Select-Object TelephoneNumber,AssignedToDisplayName,AssignedToUPN,NumberType, ActivationState, City,IsoCountryCode,IsoSubdivision,PortInOrderStatus, PstnAssignmentStatus,PstnPartnerName, Capability
  $mcoll.TelephoneNumber = $voicenumber.TelephoneNumber
  $mcoll.PstnPartnerName = $voicenumber.PstnPartnerName
  $mcoll.NumberType = $voicenumber.NumberType
  $mcoll.ActivationState = $voicenumber.ActivationState
  $mcoll.City = $voicenumber.City
  $mcoll.IsoCountryCode = $voicenumber.IsoCountryCode
  $mcoll.IsoSubdivision = $voicenumber.IsoSubdivision
  $mcoll.PortInOrderStatus = $voicenumber.PortInOrderStatus
  $mcoll.PstnAssignmentStatus = $voicenumber.PstnAssignmentStatus
  $mcoll.Capability = -join $voicenumber.Capability
  
  if($voicenumber.PstnAssignmentStatus -eq "UserAssigned" -Or $voicenumber.PstnAssignmentStatus -eq "VoiceApplicationAssigned"){
    $lineuri = $assigneduser = $null
    $lineuri = "tel:" + $voicenumber.TelephoneNumber
    $assigneduser = $getllcsonlineusernumbers | where{$_.LineURI -eq $lineuri} | select UserPrincipalName,DisplayName
    $mcoll.AssignedToUPN = $assigneduser.UserPrincipalName
    $mcoll.AssignedToDisplayName = $assigneduser.DisplayName
  }
  $collection.Add($mcoll) | out-null
}
Write-Log -Message "Data collected, export to CSV" -path $log
$collection | Export-Csv $Report1 -NoTypeInformation
#Disconnect-MicrosoftTeams
##############################Recycle Logs##########################
Write-Log -Message "Recycle Logs" -path $log -Severity Information
Write-Log -message "Finish..................Script" -path $log
#Send-MailMessage -SmtpServer $smtpserver -From $from -To $erroremail -Subject "Report - AvailableTeamNumbersReport" -Body "Report - AvailableTeamNumbersReport" -Attachments $report1
#############################################################################################