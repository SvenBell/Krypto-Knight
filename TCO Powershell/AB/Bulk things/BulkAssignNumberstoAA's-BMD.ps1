#Connect to Microsoft Teams Module
Connect-MicrosoftTeams
#Load CSV to powershell variable
$Filename = ".\0730339500-9599_Service.csv"
#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
    #Create variables from csv columns
    #$aaname = $user.aaname
    $number = $user.Number
    $upn = $user.UPN
    #Find Resource account UPN by searching via Displayname
    #$upn = Get-CsOnlineApplicationInstance | Where-Object {$_.DisplayName -eq "$aaname"} | select UserPrincipalName
    #Log Resource account details before change
    #Get-CsOnlineApplicationInstance | Where-Object {$_.DisplayName -eq "$aaname"} | Select DisplayName,UserPrincipalName,PhoneNumber | export-csv ".\AASitename-Pre.csv" -Append -NoTypeInformation
    Get-CsOnlineApplicationInstance -identity $upn | Select DisplayName,UserPrincipalName,PhoneNumber | export-csv ".\0730339500-9599BMD-Pre.csv" -Append -NoTypeInformation
    #Add service number to resource accounts
    Set-CsOnlineVoiceApplicationInstance -identity $upn -TelephoneNumber $number -ErrorAction silentlycontinue

    #Get-CsOnlineApplicationInstance -Identity "teams_aa_resource_16@onbmd.onmicrosoft.com"
    #Set-CsOnlineVoiceApplicationInstance -id "teams_aa_resource_16@onbmd.onmicrosoft.com" -TelephoneNumber "61738937400"

    if($? -ne 'False')
    {
    write-host 'Display Name' $upn -ForegroundColor Red
    write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor DarkRed}
    else{
    #Display line to track progress through foreach loop
    write-host 'Assigning number' $number 'to' $upn -ForegroundColor DarkCyan
    }
    #Log Resource account details after change
    #Get-CsOnlineApplicationInstance | Where-Object {$_.DisplayName -eq "$aaname"} | Select DisplayName,UserPrincipalName,PhoneNumber | export-csv ".\AASitename-Post.csv" -Append -NoTypeInformation
    Get-CsOnlineApplicationInstance -identity $upn | Select DisplayName,UserPrincipalName,PhoneNumber | export-csv ".\0730339500-9599BMD-Post.csv" -Append -NoTypeInformation
    }

Disconnect-MicrosoftTeams