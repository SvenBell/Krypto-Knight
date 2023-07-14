# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

#Global Variables
$FunctionName = "startDSCreport"
$TemplatePath = "D:\home\site\wwwroot\$FunctionName\bin\DSC\M365TenantConfig.ps1"

#Import Powershell Modules
$ModuleCSVpath = "D:\home\site\wwwroot\$FunctionName\bin\modules.csv"

Import-Csv -path $ModuleCSVpath | ForEach-Object {
    
    $PSModulePath = "D:\home\site\wwwroot\$FunctionName\bin\$($_.Name)\$($_.Version)\$($_.Name).psd1"
    Write-Host = $PSModulePath

    #Importing Powershell Modules
    Import-module $PSModulePath -global -noclobber -verbose -UseWindowsPowerShell
    $res = 'D:\home\wwwroot\$FunctionName\bin'
    Write-Host = "Importing $($_.Name) Powershell Module at Version $($_.Version)"
}

#Build Credentials
$username = $Env:user
$pw = $Env:password

$keypath = "D:\home\site\wwwroot\$FunctionName\bin\keys\PassEncryptKey.key"
$secpassword = $pw | ConvertTo-SecureString -Key (Get-Content $keypath)
$credential = New-Object System.Management.Automation.PSCredential ($username, $secpassword)

#Report Microsoft365 DSC
Assert-M365DSCTemplate -TemplatePath $TemplatePath -GlobalAdminAccount $credential

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
