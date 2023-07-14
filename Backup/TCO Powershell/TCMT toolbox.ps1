Connect-MicrosoftTeams

#####################################################################################################
$user = "[USERNAME]@[COMPANY].com"
$phoneno = "+6499756614"
$DialPlan = "NZ-09"
$RoutingPolicy = "NZ-TCMT-AllCalls"
$CallerIDName = "AA-Auckland"
##############################################################################
# Verify correct policies have been assigned to user
Get-CsOnlineUser -Identity $user | Format-List -Property FirstName, LastName, EnterpriseVoiceEnabled, HostedVoiceMail, LineURI, OnPremLineURI, UsageLocation, UserPrincipalName, WindowsEmailAddress, SipAddress, OnlineVoiceRoutingPolicy, TenantDialPlan, CallerIDPolicy, CallingLineIdentity

# Assign Calling Restriction to user
Grant-CsOnlineVoiceRoutingPolicy -Identity $User -PolicyName $RoutingPolicy

# Assign Phone Number to User
# OLD - Set-CsUser -Identity $User -OnPremLineURI $phoneno -EnterpriseVoiceEnabled $true -HostedVoiceMail $true 
Set-CsPhoneNumberAssignment -Identity $user -PhoneNumber $phoneno -PhoneNumberType DirectRouting
# NOTE - If a user or resource account has a phone number set in Active Directory on-premises and synched into Microsoft 365, you can't use Set-CsPhoneNumberAssignment to set the phone number. 
# You will have to clear the phone number from the on-premises Active Directory and let that change sync into Microsoft 365 first.
#
# Set phone system only user as call queue agent
#Set-CsPhoneNumberAssignment -Identity $user -EnterpriseVoiceEnabled $true

#Assign user a Dail Plan policy
Grant-CsTenantDialPlan -Identity $User -PolicyName $DialPlan

#Assign Caller-ID policy to User object
Grant-CsCallingLineIdentity -Identity $User -PolicyName $CallerIDName

# Wait 50 secs - Sometime longer for the grants/sets to take effect/sync
Start-Sleep -s 60

# Verify correct policies have been assigned to user
Get-CsOnlineUser -Identity $user | Format-List -Property FirstName, LastName, EnterpriseVoiceEnabled, HostedVoiceMail, LineURI, OnPremLineURI, UsageLocation, UserPrincipalName, WindowsEmailAddress, SipAddress, OnlineVoiceRoutingPolicy, TenantDialPlan, CallerIDPolicy, CallingLineIdentity

# Get a list of assigned numbers (Call plan and Direct Route)
#Get-CsOnlineUser | Where-Object  { $_.LineURI -notlike $null } | ft DisplayName,UserPrincipalName,LineURI
#######################################################################################################
$AACQUPN = "[USERNAME]@[COMPANY].com"
$AACQDDI = "+6499861200"
$CallerIDName = "AA-Auckland"
# Assign a DDI number to AA/CQ resource account
#Set-CsOnlineApplicationInstance -Identity $AACQUPN -OnpremPhoneNumber $AACQDDI
Set-CsPhoneNumberAssignment -Identity $user -PhoneNumber $phoneno -PhoneNumberType DirectRouting
# Get assignment details of AA/CQ resource account
Get-CsOnlineApplicationInstance -Identity $AACQUPN

###############################################################################
# Lists all Voice Routing Policies
Get-CsOnlineVoiceRoutingPolicy

# Assgin voice routing policy to AA/CQ
Grant-CsOnlineVoiceRoutingPolicy -Identity $AACQUPN -PolicyName "NZ-TCMT-AllCalls"

# See voice routing polciy assignment of AA/CQ Resource account
Get-CsOnlineUser -Identity $AACQUPN | Format-List -Property FirstName, LastName, EnterpriseVoiceEnabled, HostedVoiceMail, LineURI, OnPremLineURI, UsageLocation, UserPrincipalName, WindowsEmailAddress, SipAddress, OnlineVoiceRoutingPolicy, TenantDialPlan, CallerIDPolicy, CallingLineIdentity

###############################################################################
# List current Caller ID policies
Get-CSCallingLineIdentity | fl

# Create a new Caller ID policy
New-CsCallingLineIdentity  -Identity $CallerIDName -Description "Mask outbound calls with the AA-Auckland DDI"

# Get the Resource Account Object details including ObjectId for next command
$ResourceAccount = Get-CsOnlineApplicationInstance -Identity $AACQUPN

# Set Caller ID Policy to LineURI as on creation starts as copy of Global which is Service Number and can't change directly to Resource Account type 
Set-CsCallingLineIdentity -Identity $CallerIDName -CallingIDSubstitute LineUri

# Now set Caller ID Policy to Resource Account type
Set-CsCallingLineIdentity -Identity $CallerIDName -CallingIDSubstitute Resource -ResourceAccount $ResourceAccount.ObjectId

# Now get the Caller-ID Policy details
Get-CSCallingLineIdentity -Identity $CallerIDName

# Change existing Caller ID policy
# Set-CsCallingLineIdentity -Identity $CallerIDName -CallingIDSubstitute Resource -ResourceAccount $ResourceAccount.ObjectId

# Assign Caller-ID policy to User object
Grant-CsCallingLineIdentity -Identity $User -PolicyName $CallerIDName

# Verify correct policies have been assigned to user
Get-CsOnlineUser -Identity $user | Format-List -Property FirstName, LastName, EnterpriseVoiceEnabled, HostedVoiceMail, LineURI, OnPremLineURI, UsageLocation, UserPrincipalName, WindowsEmailAddress, SipAddress, OnlineVoiceRoutingPolicy, TenantDialPlan, CallerIDPolicy, CallingLineIdentity
