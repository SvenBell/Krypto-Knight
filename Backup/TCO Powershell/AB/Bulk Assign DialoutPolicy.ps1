
Connect-MicrosoftTeams
#Get command here for reference
#Get-CsOnlineDialOutPolicy

$Filename = "C:\tools\Temp\GCWA-User-numbers-1605.csv"

#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
    $upn = $user.UPN
    $outboundpolicy = $user.outbound
    #Log Users current DialoutPolicy
    Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\tools\temp\Pre-GCWA-DialOutPolicy.csv" -Append -NoTypeInformation
    #Display to screen
    write-host $upn "assigning dial out policy" $outboundpolicy -foregroundcolor Green
    #Set users DialOutpolicy
    Grant-CsDialoutPolicy -id $upn -PolicyName $outboundpolicy
    #Log Users new DialoutPolicy
    Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\tools\temp\Post-GCWA-DialOutPolicy.csv" -Append -NoTypeInformation
    }

Remove-PSSession



