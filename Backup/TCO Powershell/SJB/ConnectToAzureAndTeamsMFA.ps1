#Install-PackageProvider Nuget
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls11,Tls12'
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Import MicrosoftTeams
Install-Module -Name MicrosoftTeams -Force 
#Create session with Active Directory
$sfbSession=New-CsOnlineSession -Verbose
Import-PSSession $sfbSession
Install-Module AzureAD -Force
Write-Output "Connect to Azure AD"
Connect-AzureAd 
Write-Output "Connect to MS Teams"
Connect-MicrosoftTeams 
