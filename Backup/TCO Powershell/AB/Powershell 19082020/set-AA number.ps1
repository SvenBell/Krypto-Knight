Import-Module "C:\\Program Files\\Common Files\\Skype for Business Online\\Modules\\SkypeOnlineConnector\\SkypeOnlineConnector.psd1"
$credential = Get-Credential
$session = New-CsOnlineSession -Credential $credential
Import-PSSession $session
Connect-MsolService -Credential $credential


Get-CsOnlineApplicationInstance

get-csonline

Get-CsOnlineTelephoneNumber -TelephoneNumber "61293669701"


c9b59ae9-9948-4d0b-b4d2-4d4002f4787d

set-csonlinevoiceapplicationinstance -id "c9b59ae9-9948-4d0b-b4d2-4d4002f4787d" -telephonenumber "61293669701"


61293669701
AAAU-EPX@greenlightclinical.com

set-csonlinevoiceapplicationinstance -identity 


Get-PSSession | Remove-PSSession



notepad.exe $profile