
Install-Module -Name ExchangeOnlineManagement
Install-Module PowershellGet -Force
import-module ExchangeOnlineManagement
Connect-ExchangeOnline -Credential $Credential



$MobileDevice = Get-MobileDevice -Mailbox theresa.moltoni@iriqlaw.com.au -Filter {DeviceAccessState -eq 'Quarantined'}
# allow the device
Set-CASMailbox -Identity theresa.moltoni@iriqlaw.com.au -ActiveSyncAllowedDeviceIDs $MobileDevice.DeviceId
Get-CASMailbox -Identity theresa.moltoni@iriqlaw.com.au
Set-MobileDeviceMailboxPolicy

$MobileDevice.DeviceAccessState = 'Allowed'
$MobileDevice.DeviceAccessStateReason = 'Individual'

Get-ActiveSyncOrganizationSettings

