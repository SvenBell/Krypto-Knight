#Set-ExecutionPolicy unrestricted -force
Set-ExecutionPolicy unrestricted -Scope CurrentUser -force
#Set-ExecutionPolicy -Scope CurrentUser
## Import-Module SkypeOnlineConnector
#$cred = Get-Credential
#$session = New-CsOnlineSession -Credential $cred -Verbose
## $session = New-CsOnlineSession
#New-csonlineSession
## Import-PSSession -Session $session
#$TenantID = "e246235b-d301-41f8-b9dd-756c6ac9b294"
Connect-MicrosoftTeams #-TenantId $TenantID #Customers Tenant ID
#Connect-AzureAD #-TenantID $TenantID
#Import-PSSession -Session
# Some Common Commands:
#Get-CsOnlineUser -Identity "sip:vm-main1@entag.com.au"
#Get-CsOnlineUser -Identity "sip:vm-Main1@entag.com.au" | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
#Set-CsUser -Identity "sip:vm-Main1@entag.com.au" -HostedVoiceMail $true
#Set-CsUser -Identity "sip:vm-Main1@entag.com.au" -EnterpriseVoiceEnabled $true
#Set-CsUser -Identity "sip:vm-Main1@entag.com.au" -HostedVoiceMail $true -EnterpriseVoiceEnabled $true
#Get-CsOnlineUser -Identity "sip:vm-Main1@entag.com.au" | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
#
#Set-CsOnlineVoiceUser -id s.rideout@abacusdx.com -TelephoneNumber +61733867913 -Verbose
#
#Write-Host "Hello."
#Write-Output $test
#$test = Get-CsOnlineUser -Identity "sip:vm-Main1@entag.com.au" | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
#Get-CsOnlineUser -Identity "sip:vm-Main1@entag.com.au" | fl Alias,EnterpriseVoiceEnabled,Lineuri,Hostedvoicemail,hostedvoicemailpolicy
#
#Get-CsCallingLineIdentity |fl
#
#New-CsCallingLineIdentity -Identity "ForensicMainAA" -CallingIdSubstitute "Service" -ServiceNumber "61753708104" -EnableUserOverride $false -Verbose
#Grant-CsCallingLineIdentity -PolicyName ForensicMainAA -Identity "Steven Ponsonby"
#
#Set-CsCallingLineIdentity -Identity "Global" -CallingIDSubstitute "Service" -ServiceNumber "61262858000"
#
#Set-CsTeamsCallParkPolicy -Identity Global -AllowCallPark $trueanothe
#Grant-CsTeamsCallParkPolicy -PolicyName Global -Identity "Stephen Bell"
#Get-CsTeamsCallParkPolicy -Identity Global
#
#Set-CsCallingLineIdentity -Identity "Global" -CallingIDSubstitute Anonymous
#Set-CsCallingLineIdentity -Identity "Global" -CallingIDSubstitute LineUri
#Set-CsCallingLineIdentity -Identity "Global" -CallingIDSubstitute "Service" -ServiceNumber "61262858000"
#
###############################################
#
#Set-CsCallQueue -Identity 6b8624fc-b711-43d0-b537-bd59381d114e -TimeoutAction Forward -TimeoutActionTarget 447d9150-cff5-481f-97be-fa705a6bb06a
#
#Set-CsCallQueue -Identity 6b8624fc-b711-43d0-b537-bd59381d114e -TimeoutAction Voicemail -TimeoutActionTarget 447d9150-cff5-481f-97be-fa705a6bb06a
#
# Tenant Dial Plan --- Ref: https://ucplanet.wordpress.com/2017/06/11/office-365-tenant-dial-plans/
# List current Tenant Dial Plans
#Get-CsTenantDialPlan
#
# Assign a tenant dial plan to a user
#Grant-CsTenantDialPlan -identity first.last@domain.com.au -PolicyName AU-QLD-07
#Grant-CsTenantDialPlan -identity first.last@domain.com.au -PolicyName AU-NSW-ACT-02
#Grant-CsTenantDialPlan -identity first.last@domain.com.au -PolicyName AU-VIC-TAS-03
#Grant-CsTenantDialPlan -identity first.last@domain.com.au -PolicyName AU-SA-WA-NT-08
#
# View the normalization rules associated with a tenant dial plan
#(Get-CsTenantDialPlan AU-NSW-ACT-02).NormalizationRules
#
# Determine the effective dial plan for a specific user (Note. can take a few minutes for changes to take effect)
#Get-CsEffectiveTenantDialPlan -Identity first.last@domain.com.au
#
# Test the outcome a specific user dialing a number
#Get-CsEffectiveTenantDialPlan -Identity first.last@domain.com.au | Test-CsEffectiveTenantDialPlan -DialedNumber 12345678
# or
#Test-CsEffectiveTenantDialPlan -DialedNumber 56411887 -Identity first.last@domain.com.au
#
# Remove a dial plan for a specific user (user then defaults to Global Tenant Dial Plan)
#Grant-CsTenantDialPlan -Identity first.last@domain.com.au -PolicyName $null
#
# Remove a Tenant Dial Plan (Requires no users assigned)
#Remove-CsTenantDialPlan -Identity AU-SA-WA-NT-08
#
#(Get-CsEffectiveTenantDialPlan -Identity first.last@domain.com.au).EffectiveTenantDialPlanName
#
# Check handy Teams user details
#Get-CsOnlineUser -Identity "sip:first.last@domain.com.au" | fl FirstName,LastName,Alias,EnterpriseVoiceEnabled,Lineuri,SipAddress,Hostedvoicemail,hostedvoicemailpolicy,DailPlan,TenantDialPlan
#
######################################
# Assign and AutoAttendant a number:
######################################
#Get-CsOnlineApplicationInstance -Identity aa-healthyminds-q@ncphn.org.au |fl
#
#Set-CsOnlineVoiceApplicationInstance -Identity aa-healthyminds-q@ncphn.org.au -TelephoneNumber "61266591822"
#
#Good user overview onliner
#Get-CsOnlineUser stephen.bell@entag.com.au | Format-List UserPrincipalName, DisplayName, SipAddress, Enabled, TeamsUpgradeEffectiveMode, `EnterpriseVoiceEnabled, HostedVoiceMail, City, UsageLocation, DialPlan, TenantDialPlan, OnlineVoiceRoutingPolicy, `LineURI, OnPremLineURI, OnlineAudioConferencingRoutingPolicy, OnlineDialOutPolicy, TeamsVideoInteropServicePolicy, TeamsCallingPolicy, HostingProvider, `InterpretedUserType, VoicePolicy, TeamsIPPhonePolicy

#DIAL PAD CONFIGURATION - Ref. https://docs.microsoft.com/en-us/microsoftteams/dial-pad-configuration
#
#In the Teams client, the dial pad enables users to access Public Switched Telephone Network (PSTN) functionality.
#The dial pad is available for users with a Phone System license, provided they are configured properly.
#The following criteria are all required for the dial pad to show:
#
#-User has an enabled Phone System (“MCOEV”) license
#-User has Microsoft Calling Plan or is enabled for Direct Routing
#-User has Enterprise Voice enabled
#-User is homed online and not in Skype for Business on premises
#-User has Teams Calling Policy enabled
#The following sections describe how to use PowerShell to check the criteria. In most cases, you need to look at various properties in the output of the Get-CsOnlineUser cmdlet. Examples assume $user is either the UPN or sip address of the user.
#
#User has an enabled Phone System (“MCOEV”) license
#You must ensure that the assigned plan for the user shows the CapabilityStatus attribute set to Enabled and the Capability Plan set to MCOEV (Phone System license). You might see MCOEV, MCOEV1, and so on. All are acceptable--as long as the Capability Plan starts with MCOEV.
#
#To check that the attributes are set correctly, use the following command:
#$user="tcoe5@entag.com.au"

#Get-CsOnlineUser -Identity $user|select AssignedPlan|fl

#Get-CsOnlineUser -Identity $user|Select OnlineVoiceRoutingPolicy

#Get-CsOnlineUser -Identity $user|Select EnterpriseVoiceEnabled

#Get-CsOnlineUser -Identity $user|Select RegistrarPool, HostingProvider

#if (($p=(get-csonlineuser -Identity $user).TeamsCallingPolicy) -eq $null) {Get-CsTeamsCallingPolicy -Identity global} else {get-csteamscallingpolicy -Identity $p}

#Get-CsOnlineUser -Identity $user|Select McoValidationError

######################################
#Set Tenant to Teams Only mode
######################################
#Grant-CsTeamsUpgradePolicy -PolicyName UpgradeToTeams -Global
#

######################################
# Common Area Phone policy commands
######################################
#
#get-csteamsipphonepolicy
#
#New-CsTeamsIPPhonePolicy -Identity "CommonAreaPhone" -Description "Common Area Phone device policy" -SignInMode CommonAreaPhoneSignIn
#or,
#New-CsTeamsIPPhonePolicy –Identity 'Meeting Sign in' –Description 'Meeting Sign In Phone Policy' -SignInMode 'MeetingSignIn'
#refer: https://learn.microsoft.com/en-us/microsoftteams/devices/Teams-Android-devices-user-interface#override-automatic-user-interface-detection
#as Meeting sign in mode will require E3 or E5 or Meeting room license as opposed to just Common Are license.
#
#Grant-CsTeamsIPPhonePolicy -Identity meetingRm-Councillor@sjshirewagovau.onmicrosoft.com -PolicyName "CommonAreaPhone"
#or,
#Grant-CsTeamsIPPhonePolicy –Identity 'conf-adams@contoso.com' –PolicyName 'Meeting Sign In'
#
#Get-CsOnlineUser -Identity meetingRm-Councillor@sjshirewagovau.onmicrosoft.com | Select-Object TeamsIPPhonePolicy

######################################
# get-CsTeamsCallingPolicy -id "Global"
# Set-CsTeamsCallingPolicy -id "Global" -BusyOnBusyEnabledType "unanswered"
# get-CsTeamsCallingPolicy -id "Global"
### This put Busy on Busy on and in this mode for Global policy, in GUI it will show as off still due to GUI bug
#

#########################################
# Output detailed phone directory to .CSV
#########################################
#Get-CsOnlineUser | Where-Object  { $_.LineURI -notlike $null } | select UserPrincipalName, DisplayName, SipAddress, Enabled, TeamsUpgradeEffectiveMode, EnterpriseVoiceEnabled, HostedVoiceMail, City, UsageLocation, DialPlan, TenantDialPlan, OnlineVoiceRoutingPolicy, LineURI, OnPremLineURI, OnlineDialinConferencingPolicy, TeamsVideoInteropServicePolicy, TeamsCallingPolicy, HostingProvider, InterpretedUserType, VoicePolicy | Export-CSV c:\tools\BMD-PhoneDirectory-XL.csv -NoTypeInformation
#
# Output detailed phone directory to .CSV for as built
#Get-CsOnlineUser | Where-Object  { $_.LineURI -notlike $null } | select DisplayName, UserPrincipalName, LineURI, UsageLocation, EnterpriseVoiceEnabled, TenantDialPlan, OnlineVoiceRoutingPolicy, OnlineDialOutPolicy, TeamsCallingPolicy, CallingLineIdentity, AssignedPlan -ExpandProperty AssignedPlan | Export-CSV c:\temp\FKG-PhoneDirectoryv11.csv -NoTypeInformation

#Produce list of Call Queues
#Get-CsCallqueue -first 100 | select-object Name,Identity,ApplicationInstances,RoutingMethod,DistributionLists,Agents,AgentsInSyncWithDistributionLists,AllowOptOut,AgentsCapped,AgentAlertTime,OverflowThreshold,OverflowAction,@{Label="OverflowactionTarget";Expression={($_.OverflowactionTarget.Id)}}, @{Label="TimeoutActionTarget";Expression={($_.TimeoutActionTarget.Id)}} |export-csv -notypeinformation -append "C:\temp\ADGCEcqdata.csv" 
#
#$allNumbers = Get-CsOnlineTelephoneNumber -ResultSize 2147483647
#$allNumbers | Export-CSV c:\tools\ENTAG-Full-Directory.csv -NoTypeInformation
#
#$allNumbers = Get-CsPhoneNumberAssignment
#$allNumbers | Export-CSV c:\tools\ENTAG-Full-Directory.csv -NoTypeInformation
#
#https://msunified.net/2021/08/18/find-available-phone-numbers-with-get-teamsnumbers-ps1/
#

#################################################
# SYnc Teams PSTN number with AD telephone number
#################################################
# https://goziro.com/how-to-sync-microsoft-teams-phone-numbers-with-active-directory/
#

################################
#Check users for onpremise Issue
################################
#Get-CsOnlineUser -Filter {OnPremLineURIManuallySet -eq $False -and EnterpriseVoiceEnabled -eq $true}  |  Format-Table UserPrincipalName, LineURI, OnPremLineURI, VoicePolicy, OnPremLineURIManuallySet, EnterpriseVoiceEnabled
#Get-CsOnlineUser h.messenger@abacusdx.com | Format-List UserPrincipalName, DisplayName, SipAddress, Enabled, TeamsUpgradeEffectiveMode, `EnterpriseVoiceEnabled, HostedVoiceMail, City, UsageLocation, DialPlan, TenantDialPlan, OnlineVoiceRoutingPolicy, `LineURI, OnPremLineURI, OnlineDialinConferencingPolicy, TeamsVideoInteropServicePolicy, TeamsCallingPolicy, HostingProvider, `InterpretedUserType, VoicePolicy
#

#######################################
#Block International calls
#######################################
#Get-CsOnlineDialOutPolicy
#
#Get-CsOnlineUser kaleb.toigo@tbtcbrisbanecity.com.au | Format-List UserPrincipalName, DisplayName, EnterpriseVoiceEnabled, DialPlan, LineURI, OnlineDialOutPolicy
#
#Make Outbound calls domestic only as global default - Can assign individual users international as required
#Grant-CsDialoutPolicy -PolicyName DialoutCPCInternationalPSTNDomestic  -Global
#
#Grant-CsDialoutPolicy -Identity <username> -PolicyName <policy name>
#
#Grant-CsDialoutPolicy -identity Uheina.McDonald@qfcc.qld.gov.au -PolicyName Global
#Grant-CsDialoutPolicy -identity Uheina.McDonald@qfcc.qld.gov.au -PolicyName DialoutCPCDisabledPSTNDomestic
#Grant-CsDialoutPolicy -identity Uheina.McDonald@qfcc.qld.gov.au -PolicyName DialoutCPCandPSTNInternational

######################################
# Block specific in bound numbers
######################################
#
# First list current blocked numbers:
# Get-CsInboundBlockedNumberPattern    
#
# to add new blocked number:
# New-CsInboundBlockedNumberPattern -Name "BlockNumber0433581234" -Enabled $True -Description "Block 0433581234" -Pattern "^\+?61433581234$"
#
# Confirm by listing current blocked numbers again:
# Get-CsInboundBlockedNumberPattern
#
#
# Test-CsInboundBlockedNumberPattern -PhoneNumber "433581234"
#
# Remove-CsInboundBlockedNumberPattern
#

########################################
##Use Proxy for Fiddler capture of powershell
#winhttp set proxy localhost:8888
##Need to set system proxt to capture TAC GUI
#
##To set back to direct access
#netsh winhttp reset proxy
########################################
#

########################################
# Set Call Park 
########################################
# Set-CsTeamsCallParkPolicy -Identity SalesPolicy -AllowCallPark $true
#
########################################
# 365 Group Voicemail subscription 
########################################
# 
# Import-Module ExchangeOnlineManagement
# Connect-ExchangeOnline -UserPrincipalName stephen.bell@YYYYYYY.com.au
# 
# Get-UnifiedGroup | Format-Table Name,*subscribe* -AutoSize
# Get-UnifiedGroup "XXXXXVM@YYYYY.com.au" | Get-UnifiedGroupLinks -LinkType Subscribers
# Get-UnifiedGroup -Identity "XXXXXVM@YYYYY.com.au"

################################################################
## New command to assign numbers to Users/Resource accounts:
## -PhoneNumberType  The type of phone number to unassign from the user or resource account. The supported values are DirectRouting, CallingPlan and OperatorConnect.
#Set-CsPhoneNumberAssignment -Identity user1@contoso.com -PhoneNumber +12065551234 -PhoneNumberType CallingPlan
#
## Unassign phone number from a user or resource account.
#Remove-CsPhoneNumberAssignment -Identity user1@contoso.com -PhoneNumber +12065551234 -PhoneNumberType CallingPlan
## or,
#Remove-CsPhoneNumberAssignment -Identity user2@contoso.com -RemoveAll
#
## Enable Enterprise Voice
#Set-CsPhoneNumberAssignment -Identity user3@contoso.com -EnterpriseVoiceEnabled $true
#
## This example assigns the Direct Routing phone number +1 (425) 555-1225 to the resource account cq1@contoso.com.
#Set-CsPhoneNumberAssignment -Identity cq1@contoso.com -PhoneNumber +14255551225 -PhoneNumberType DirectRouting
#or, for Calling plan number:
#Set-CsPhoneNumberAssignment -Identity user1@contoso.com -PhoneNumber +12065551234 -PhoneNumberType CallingPlan
#
#Block a number at an organisational level
#New-CsInboundBlockedNumberPattern -Name “Block Spammer 1” -Enabled $True -Description “Blocks 0432 664 593 from calling Dead Judges” -Pattern “^[+]?61432664593”

#############################################
# Set user's call settings to forward to a CQ
#
# Set-CsUserCallingSettings -Identity stephen.bell@entag.com.au -IsUnansweredEnabled $true -UnansweredTargetType SingleTarget -UnansweredTarget sip:CQ-Stephen-Test1@entag.com.au -UnansweredDelay 00:00:20
#

#############################################
# List all Resource accounts and check Type and Phone number assigned
#############################################
#
# Get-CsOnlineApplicationInstance
#
# Auto Attendant: ce933385-9390-45d1-9512-c8d228074e07 
# Call Queue: 11cd3e2e-fccb-42ad-ad00-878b93575e07
#

#############################################
# Bulk releasing phones numbers for operator connect
#############################################

#Get all unassigned phone numbers to ensure numbers are removed from users or resources accounts
# Get-CsPhoneNumberAssignment -ActivationState Activated -pstnassignmentstatus unassigned

#Get list of numbers in a range
# $numbers= Get-Csphonenumberassignment -TelephoneNumberContain "543986"

#variable stores multiple numbers like a string
# Remove-csonlinetelephonenumber -TelephoneNumber $numbers.telephonenumber

#Results displayed like below
#PS C:\Users\AndrewBaird> Remove-csonlinetelephonenumber -TelephoneNumber $numbers.telephonenumber
#
#NumberIdsAssigned NumberIdsDeleteFailed NumberIdsDeleted                                            NumberIdsManagedByServiceDesk NumberIdsNotOwnedByTenant
#----------------- --------------------- ----------------                                            ----------------------------- -------------------------
#{}                {}                    {+61754398603, +61754398623, +61754398615, +61754398600...} {}                            {}                       
#
#