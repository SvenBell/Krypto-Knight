#Connect to Microsoft Teams Module
Connect-MicrosoftTeams
#Load CSV to powershell variable
$Filename = "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\Sunshine Coast Council\0. SSC - TELECOMMUNICATIONS PROJECT\Streams\TCO\CoolumLibrary\Coolumlibrary-Service.csv"
#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
    #Create variables from csv columns
    $aaname = $user.resourcename
    $number = $user.tiptnumber
    #Find Resource account UPN by searching via Displayname
    $upn = Get-CsOnlineApplicationInstance | Where-Object {$_.DisplayName -eq "$aaname"} | select UserPrincipalName
    #Log Resource account details before change
    Get-CsOnlineApplicationInstance | Where-Object {$_.DisplayName -eq "$aaname"} | Select DisplayName,UserPrincipalName,PhoneNumber | export-csv "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\Sunshine Coast Council\0. SSC - TELECOMMUNICATIONS PROJECT\Streams\TCO\CoolumLibrary\ResourceCoolumlibrary-Pre.csv" -Append -NoTypeInformation
    #Add service number to resource accounts
    Set-CsOnlineVoiceApplicationInstance -id $upn.UserPrincipalName -TelephoneNumber $number -ErrorAction silentlycontinue
    if($? -ne 'False')
    {
    write-host 'Display Name' $aaname -ForegroundColor Red
    write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor DarkRed}
    else{
    #Display line to track progress through foreach loop
    write-host 'Assigning number' $number 'to' $upn.UserPrincipalName -ForegroundColor DarkCyan
    }
    #Log Resource account details after change
    Get-CsOnlineApplicationInstance | Where-Object {$_.DisplayName -eq "$aaname"} | Select DisplayName,UserPrincipalName,PhoneNumber | export-csv "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\Sunshine Coast Council\0. SSC - TELECOMMUNICATIONS PROJECT\Streams\TCO\CoolumLibrary\ResourceCoolumlibrary-Post.csv" -Append -NoTypeInformation
    }

Disconnect-MicrosoftTeams