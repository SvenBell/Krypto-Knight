$cred=Get-Credential
$url="https://adminau1.online.lync.com/HostedMigration/hostedmigrationService.svc"
Move-CsUser -Identity Skype.T@Scenicrim.qld.gov.au -Target sipfed.online.lync.com -Credential $cred -HostedMigrationOverrideUrl $url