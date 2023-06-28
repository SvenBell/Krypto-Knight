############################################
#Script to Create Teams Room Resources     #
#Date: 24/06/2021                          #
#Written by Andrew Pearson                 #
#Version: 1.1                              #
############################################

#import csv room names
$room_list = Import-Csv '.\room_list.csv'


#------------------Required Parameters---------------------

$pwd=""                               #room password
$licenseskuId="6070a4c8-34c6-4937-8dfb-39bbc6397a60"      #this is the SKU for the Meeting Room Licnese
$location="AU"                                            #service location
$adminupn=""                       #admininstation username
$IsWheelChairAccessible=$true                             #wheelchairaccessible
$delegateApproval=$false                                  #use the variable to define if delegate approval is required ($true = approval is required). If it is enter the distribution group of approvers below. If false the script will filter it out.

#-------------------Optional Parameters---------------------

#Distribution group details. If the group doesn't exist the script will create the group
$distName="Booking Approvers"
$distEmail="approvers@xxxx"
$distMembers="manager@xxxx"

#if you need PTSN Calling enabled set paramater below - NOTE: script is not completed for this and paramater should remain false for now.
$PTSNCallingRequired = $false

#--------------------Install Modules------------------------ (remove comments if you need it installed)
<#Install-Module -Name ExchangeOnlineManagement -Force #New modern auth and mfa supported
Install-Module -Name MicrosoftTeams -Force
Install-Module -Name AzureAD -Force -AllowClobber
#>

function CleanupAndFail {
  # Cleans up and prints an error message
    
  param
  (
    $strMsg
  )
  if ($strMsg)
    {
        PrintError -strMsg ($strMsg)
    }
    Cleanup
    exit 1
}

#--------------------Import Modules-------------------------
Import-Module MicrosoftTeams -Force
Import-Module ExchangeOnlineManagement -Force
Import-Module AzureAD -Force

#--------------------Connect to MS Services-----------------
Set-ExecutionPolicy RemoteSigned -Force
Connect-ExchangeOnline -UserPrincipalName $adminupn 
Connect-AzureAD -AccountId $adminupn
Connect-MicrosoftTeams -AccountId $adminupn
#>

foreach ($Room in $room_list)
{

#-----------------Creation of the room using parameters-------
try
{
    New-Mailbox -MicrosoftOnlineServicesID $Room.newRoom -Name $Room.name -Room -RoomMailboxPassword (ConvertTo-SecureString -String $pwd -AsPlainText -Force) -EnableRoomMailboxAccount $true
}
catch
{
    CleanupAndFail -strMsg ('Failed to provision new room mailbox')
}

#----------------Taking a rest---------------------
Write-Host "Waiting 90 seconds for mailbox to be provisioned" -ForegroundColor Cyan
Write-Host $Room.newRoom
Start-Sleep -Seconds 90


#-------Set account license and password policies---------
try
{
    Set-AzureADUser -ObjectId $Room.newRoom -PasswordPolicies DisablePasswordExpiration -UsageLocation $location
    Write-Host "Password set to not expire and usage location set to $location" -ForegroundColor Cyan
}
catch
{
    CleanupAndFail -strMsg ('Failed to modify account details - set password to not expire and location')
}

#<------------Assign MS Teams Room License------------------

try
{
    $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $License.SkuId = $licenseskuId
    $Licenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $Licenses.AddLicenses = $License
    Set-AzureADUserLicense -ObjectId $Room.newRoom -AssignedLicenses $Licenses
    Write-Host "Teams Room license assigned sucessfully"
}
catch
{
    CleanupAndFail -strMsg ('Failed to assign license to the user account')
}


### Setting a MailTip for the Room and setting room capacity
try
{
    Set-Mailbox -Identity $Room.newRoom -MailTip "This room is video enabled to support Teams Meetings" -ResourceCapacity $Room.roomcapacity
    Write-Host "Room mailbox mailtip sucessfully set and resource capacity defined"
}
catch
{
    CleanupAndFail -strMsg ('Failed to set mailtip and room capacity')
}

if($delegateApproval -eq $false)
{
    ## Define the Calendar Processing Properties - Delegares ARE NOT required to approve the booking request
    $CalProcProp = @{
    AutomateProcessing = 'AutoAccept'
    AllowRecurringMeetings =$true
    AddOrganizerToSubject = $true
    RemovePrivateProperty = $false
    DeleteComments       = $false
    DeleteSubject        = $true
    AddAdditionalResponse= $true
    ProcessExternalMeetingMessages = $true
    AdditionalResponse   = "Your meeting is now scheduled and if it was enabled as a Teams Meeting will provide a seamless click-to-join experience from the conference room."

    AllBookInPolicy       = $true
    AllRequestInPolicy    = $false
    AllRequestOutOfPolicy = $false

    ResourceDelegates  = $null
    BookInPolicy       = $null
    RequestInPolicy    = $null
    RequestOutOfPolicy = $null
    }

    ## Set the Calendar Processing Properties
    try{
            Set-CalendarProcessing $Room.newRoom @CalProcProp 
            Write-Host "Calendar Processing Completed - Delegates are not required to approve the booking request"
        }
        catch
        {
            CleanupAndFail -strMsg ('Failed to assign calendar processing settings - delegates are not required to approve the booking request')
        }
}
else
{
    #-------Create distribution group if required-----------#
    if(((Get-DistributionGroup $distEmail -ErrorAction 'SilentlyContinue').IsValid) -ne $true)
        {
            New-DistributionGroup -Name $distName -Alias $distEmail -Members $distMembers
            Write-Host "Distribution Group $distName created"
        }
else
{
    Write-Host "$distName Group already exists"
}

    ## Define the Calendar Processing Properties - Delegates are required to approve the booking request
    $CalProcProp = @{

    AutomateProcessing = 'None'
    AllowRecurringMeetings =$true
    AddOrganizerToSubject = $true
    RemovePrivateProperty = $false
    DeleteComments       = $false
    DeleteSubject        = $true
    AddAdditionalResponse= $true
    ProcessExternalMeetingMessages = $true
    AdditionalResponse   = "Your meeting is now scheduled and if it was enabled as a Teams Meeting will provide a seamless click-to-join experience from the conference room."

    AllBookInPolicy       = $false
    AllRequestInPolicy    = $true
    AllRequestOutOfPolicy = $false

    ResourceDelegates  = $distName
    BookInPolicy       = $null
    RequestInPolicy    = $null
    RequestOutOfPolicy = $null
    }

## Set the Calendar Processing Properties
    try{
            Set-CalendarProcessing $Room.newRoom @CalProcProp 
            Write-Host "Calendar Processing Completed - Delegates are required to approve the booking request"
        }
        catch
        {
            CleanupAndFail -strMsg ('Failed to assign calendar processing settings - delegates are required to approve the booking request')
        }
}

Write-Host "Waiting 30 seconds (good old cloud lag)..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

try
{
    Set-Place -Identity $Room.newRoom -Building $Room.Building -DisplayDeviceName $Room.DisplayDeviceName -VideoDeviceName $Room.VideoDeviceName
    Start-Sleep -Seconds 10
    Set-Place -Identity $Room.newRoom -label $Room.label -AudioDeviceName $Room.AudioDeviceName -City $Room.City -Floor $Room.Floor -GeoCoordinates $Room.GeoCoordinates -IsWheelChairAccessible $true
    Write-Host "Room meta data sucessfully set"
}
catch
{
     CleanupAndFail -strMsg ('Failed to set metadata - please check CSV for errors and ensure all data is formatted correctly')
}

#Checking New Room Creation

Get-Mailbox -Identity $Room.newRoom | fl

<### Enabling the account for SfB Online - Find the pool first then use the name in -RegistratPool
$RegistrarPool = Get-CsOnlineUser -Identity $newRoom | Select -Expand RegistrarPool
Enable-CsMeetingRoom -Identity $newRoom -RegistrarPool $RegistrarPool -SipAddressType EmailAddress
Write-Host "Team Room enabled"

### Enable the account for Enterprise Voice
#Set-CsMeetingRoom -Identity $newRoom -EnterpriseVoiceEnabled $true

if($PTSNCallingRequired -eq $true)
{
    ### Apply a calling plan to the user if PSTN calling is required
    Set-MsolUserLicense -UserPrincipalName $newRoom –AddLicenses "reseller-account:MCOPSTNEAU2"
}

### Finding and setting allowed external meeting invites from outside the domain (Optional)
Get-Mailbox $Room.newRoom | Set-CalendarProcessing -ProcessExternalMeetingMessages $true
#>
}

### Getting Room Mailboxes ###
Get-Mailbox -RecipientTypeDetails RoomMailbox
Get-Mailbox -RecipientTypeDetails RoomMailbox | Get-CalendarProcessing | Select *external*

### View your licenses avaialble
Get-AzureADSubscribedSku | Select -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits
#>
