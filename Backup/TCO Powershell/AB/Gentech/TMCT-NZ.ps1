#New Zealand
connect-msolservice

Get-msoldomain


#Creating PSTN usages
Connect-MicrosoftTeams
Set-CsOnlinePSTNUsage -Identity global -Usage @{Add="NZ-TCMT-AllCalls"}

#Creating voice routes-Customer Domain – Primary SBC
New-CsOnlineVoiceRoute -Identity "NZ-TCMT-AllCalls-Primary" -Priority 1 -OnlinePstnUsages "NZ-TCMT-AllCalls" -OnlinePstnGatewayList gsplgnz.sp1.telstra.com -NumberPattern '^\+?\d+' -Description "Allows allcalls calls from Auckland, New Zealand"

#Creating voice routes-Customer Domain – Secondary SBC
New-CsOnlineVoiceRoute -Identity "NZ-TCMT-AllCalls-Secondary" -Priority 2 -OnlinePstnUsages "NZ-TCMT-AllCalls" -OnlinePstnGatewayList gsplgnz.he1.telstra.com -NumberPattern '^\+?\d+' -Description "Allows allcalls calls from Auckland, New Zealand"

#Creating voice policies
New-CsOnlineVoiceRoutingPolicy "NZ-TCMT-AllCalls" -OnlinePstnUsages "NZ-TCMT-AllCalls” -Description "Allows allcalls calls from Auckland, New Zealand"

#Assign Calling Restriction to user
Grant-CsOnlineVoiceRoutingPolicy -Identity "User-2TCMT@gsplgnz.sp1.telstra.com" -PolicyName "NZ-TCMT-AllCalls"



#Assign Phone Number to User
Set-CsUser -Identity "User-2TCMT@gsplgnz.sp1.telstra.com" -OnPremLineURI tel:+6469861219 -EnterpriseVoiceEnabled $true -HostedVoiceMail $true 

#Verify correct policies have been assigned to user
Get-CsOnlineUser -Identity "[USERNAME]@[COMPANY].com" | Format-List -Property FirstName, LastName, EnterpriseVoiceEnabled, HostedVoiceMail, LineURI, UsageLocation, UserPrincipalName, WindowsEmailAddress, SipAddress, OnPremLineURI, OnlineVoiceRoutingPolicy, TenantDialPlan
