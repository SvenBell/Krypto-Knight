#Setup Powershell for Teams

[Net.ServicePointManager]::SecurityProtocol =
    [Net.ServicePointManager]::SecurityProtocol -bor
    [Net.SecurityProtocolType]::Tls12

Install-PackageProvider -Name NuGet -Force

Get-PSRepository

C:\Users\a_stephenb\Downloads\CheckDotNetVersion.ps1

get-installedmodule

Register-PSRepository -Default -Verbose

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

Install-PackageProvider -Name NuGet -Force

Get-PackageProvider
Get-PackageProvider -ListAvailable

Register-PSRepository - Default -Verbose

$PSVersionTable

Get-PackageProvider

Install-Module PowerShellGet - RequiredVersion 2.2.4 -SkipPublisherCheck

Get-PSRepository -Verbose

get-installedmodule

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Get-PSRepository -Verbose

$PSVersionTable.PSVersion

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ?{$_.DisplayName -like “*Skype for Business*”} | Sort-Object DisplayName | Select DisplayName, DisplayVersion, InstallDate | Format-Table -AutoSize

Install-Module -Name MicrosoftTeams -Force -AllowClobber

Update-Module -Name MicrosoftTeams
