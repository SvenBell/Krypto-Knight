Import-Module "C:\\Program Files\\Common Files\\Skype for Business Online\\Modules\\SkypeOnlineConnector\\SkypeOnlineConnector.psd1"
$credential = Get-Credential
$session = New-CsOnlineSession -Credential $credential
Import-PSSession $session
Connect-MsolService -Credential $credential

#import-module MSOnline


#Install-Module MSOnline
#Install-Module AzureAD
#Import-Module AzureAD




Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $credential
Import-PSSession $sfboSession

winrm get winrm/config/service


Get-CsOnlineTelephoneNumber -isnotassigned -TelephoneNumberStartsWith 617558005

Get-CsOnlineTelephoneNumber -ResultSize 3000 | select FriendlyName,Id,activationstate,InventoryType,citycode,location,O365Region,UserId | export-csv C:\temp\CropsmartPhonenumberexport_02032020.csv 

Get-CsOnlineTelephoneNumber | ft | export-csv C:\temp\NCPHNPhonemumberexport4.csv

Get-CsOnlineVoiceUser | select Name,sipdomain,number,licensestate,usagelocation,enterprisevoiceenabled | export-csv C:\temp\DASSuserlist.csv 

Remove-PSSession $Session

Get-PSSession

Get-PSSession | Remove-PSSession

Remove-PSSession $sfboSession



