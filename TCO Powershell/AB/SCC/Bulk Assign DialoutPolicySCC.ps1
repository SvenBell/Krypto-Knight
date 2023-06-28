
Connect-MicrosoftTeams
#Get command here for reference
#Get-CsOnlineDialOutPolicy

$Filename = "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\Sunshine Coast Council\0. SSC - TELECOMMUNICATIONS PROJECT\Streams\TCO\TCO Migrations- Final\International Outbound Users.csv"

#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
    $upn = $user.UPN
    $outboundpolicy = $user.outboundpolicy
    #Log Users current DialoutPolicy
    #Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\temp\Pre-SCC-DialOutPolicy.csv" -Append -NoTypeInformation
    #Display to screen
    write-host $upn "assigning dial out policy" $outboundpolicy -foregroundcolor Green
    #Set users DialOutpolicy
    Grant-CsDialoutPolicy -id $upn -PolicyName $outboundpolicy
    #Log Users new DialoutPolicy
    Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\temp\Post-SCC-DialOutPolicy.csv" -Append -NoTypeInformation
    }

Remove-PSSession

Grant-CsDialoutPolicy -PolicyName $outboundpolicy  -Global 

