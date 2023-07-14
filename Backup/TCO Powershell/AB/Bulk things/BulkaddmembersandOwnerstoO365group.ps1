#VoiceMail Stage
#Need exchange module installed
#Install-Module -Name ExchangeOnlineManagement
#Install-Module PowershellGet -Force
#Add users to Voicemail group
Connect-ExchangeOnline
$VMGroup = "VM-Reception@entag.onmicrosoft.com.au"

$Filename = "C:\Users\TCO\PilotGroup-01032022.csv"


    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
$upn= $user.UPN
$VMGroup = New-UnifiedGroup -DisplayName $VmailDisplay -Alias $VmailName

Add-UnifiedGroupLinks –Identity $VMGroup –LinkType Members  –Links $upn
Add-UnifiedGroupLinks –Identity $VMGroup –LinkType Owners  –Links $upn
}