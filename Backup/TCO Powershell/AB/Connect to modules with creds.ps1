#You need to run this first to save your password as an encrypted file
#Read-Host “Enter Password” -AsSecureString |  ConvertFrom-SecureString | Out-File “C:\Scripts\Password.txt”
 
#Authenticate and connect to a new Microsoft Teams PowerShell session
$Username = “your.adminuser@domain.com”
$Password = cat “c:\Scripts\password.txt” | ConvertTo-SecureString
$Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
Connect-MicrosoftTeams -Credential $Creds
 
#Authenticate and connect to a new Exchange Online PowerShell session
Connect-ExchangeOnline -Credential $Creds -ShowProgress $true
 
#Authenticate and connect to a new Azure AD PowerShell session
Connect-MsolService -Credential $Creds
 
#Authenticate and connect to Azure AD using the Azure Active Directory PowerShell for Graph module
Connect-AzureAD -Credential $Creds