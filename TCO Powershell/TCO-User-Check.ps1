$user="steve@gjs.co"

Get-CsOnlineUser -Identity $user|select AssignedPlan|fl

Get-CsOnlineUser -Identity $user|Select OnlineVoiceRoutingPolicy| out-host

Get-CsOnlineUser -Identity $user|Select EnterpriseVoiceEnabled| out-host

Get-CsOnlineUser -Identity $user|Select RegistrarPool, HostingProvider| out-host

if (($p=(get-csonlineuser -Identity $user).TeamsCallingPolicy) -eq $null) {Get-CsTeamsCallingPolicy -Identity global} else {get-csteamscallingpolicy -Identity $p}| out-host

Get-CsOnlineUser -Identity $user|Select McoValidationError| out-host