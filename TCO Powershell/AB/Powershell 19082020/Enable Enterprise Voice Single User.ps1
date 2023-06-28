

$Session = New-CsOnlineSession
Import-PSSession $Session -AllowClobber




Set-CsUser -Identity "central-vmail@barben.com.au" -EnterpriseVoiceEnabled $true

Remove-PSSession $Session