# Draft Teams Room setup script
# Step through line by line, not run whole script

Import-Module MicrosoftTeams
Connect-MicrosoftTeams

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName stephen.bell@entag.com.au

get-Mailbox -Identity cloudroom@entag.com.au | fl UserPrincipleName, DisplayName, Identity, Id, Name, Alias, DistinguishedName, PrimarySmtpAddress, EmailAddresses, ModerationEnabled, RoomMailboxAccountEnabled, ResetPasswordOnNextLogon
Set-Mailbox -Identity cloudroom@entag.com.au -EnableRoomMailboxAccount $true -RoomMailboxPassword (ConvertTo-SecureString -String 'Cornchips77!' -AsPlainText -Force)
get-Mailbox -Identity cloudroom@entag.com.au | fl UserPrincipleName, DisplayName, Identity, Id, Name, Alias, DistinguishedName, PrimarySmtpAddress, EmailAddresses, ModerationEnabled, RoomMailboxAccountEnabled, ResetPasswordOnNextLogon


Set-CalendarProcessing -Identity "Rigel-01" -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false -AddAdditionalResponse $true -AdditionalResponse "This is a Teams Meeting room!"


Get-CsOnlineUser -Identity "stephen.bell@entag.com.au" | Select -Expand RegistrarPool
Enable-CsMeetingRoom -Identity "Rigel1@contoso.onmicrosoft.com" -RegistrarPool "sippoolbl20a04.infra.lync.com" -SipAddressType EmailAddress
