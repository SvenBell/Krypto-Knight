### Meeting Room Variables
$newRoom="lis-podroom@hnc.org.au"
$name="Lismore Pod Room"
$pwd="myS3cureP4ssw0rd!"
$license="reseller-account:MEETING_ROOM"
$location="AU"
#$orgName="hnc.org.au"
####Pre Reqs to install
Install-Module -Name MSOnline
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name AzureAD -Force -AllowClobber
### Download Skype Online PowerShell
https://www.microsoft.com/en-us/download/details.aspx?id=39366
### Install Exchange Online Module 
### change your domain below
https://outlook.office365.com/ecp/?rfr=Admin_o365&exsvurl=1&mkt=en-US&Realm=mydomain.onmicrosoft.com
### Connecting to Microsoft Online Services 
Set-ExecutionPolicy RemoteSigned

#$credential = Get-Credential #Doesnt work with MFA
Connect-MsolService #-Credential $credential
#Connect-MicrosoftTeams
#Import-Module SkypeOnlineConnector
#$sfboSession = New-CsOnlineSession #-Credential $credential
#Import-PSSession $sfboSession
$credential = Get-Credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking
### View your licenses avaialble
Get-MsolAccountSku
### Creating a new Account
New-Mailbox -MicrosoftOnlineServicesID $newRoom -Name $name -Room -RoomMailboxPassword (ConvertTo-SecureString -String $pwd -AsPlainText -Force) -EnableRoomMailboxAccount $true

### Wait one minute before configuring the new account
Set-MsolUser -UserPrincipalName $newRoom -PasswordNeverExpires $true -UsageLocation $location

### Assigning a license to the room account
Set-MsolUserLicense -UserPrincipalName $newRoom -AddLicenses $license
### Setting a MailTip for the Room
Set-Mailbox -Identity $newRoom -MailTip "This room is video enabled to support Teams Meetings"
### Configs the account to process requests
Set-CalendarProcessing -Identity $newRoom -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -RemovePrivateProperty $false -DeleteComments $false -DeleteSubject $false -AddAdditionalResponse $true -AdditionalResponse "Your meeting is now scheduled and if it was enabled as a Teams Meeting will provide a seamless click-to-join experience from the conference room." 
### Enabling the account for SfB Online - Find the pool first then use the name in -RegistratPool
Get-CsOnlineUser |ft RegistrarPool

### Wait a few minutes before running this next command
Enable-CsMeetingRoom -Identity $newRoom -SipAddressType "EmailAddress" -RegistrarPool "sippoolme1au104.infra.lync.com"
### Enable the account for Enterprise Voice
Set-CsMeetingRoom -Identity $newRoom -EnterpriseVoiceEnabled $true

### Apply a calling plan to the user if PSTN calling is required
Set-MsolUserLicense -UserPrincipalName $newRoom –AddLicenses "reseller-account:MCOPSTNEAU2"

#### Option Configuration 
### Getting Room Mailboxes ###
Get-Mailbox -RecipientTypeDetails RoomMailbox
### Finding and setting allowed external meeting invites from outside the domain
Get-Mailbox $name | Get-CalendarProcessing | Select *external*
Get-Mailbox $name | Set-CalendarProcessing -ProcessExternalMeetingMessages $true

### Checking the Meeting Room Configuration
Get-CsMeetingRoom -Identity $newroom
Get-Mailbox -Identity $newroom | fl