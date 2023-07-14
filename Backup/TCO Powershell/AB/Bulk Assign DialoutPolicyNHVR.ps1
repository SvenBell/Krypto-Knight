
Connect-MicrosoftTeams
#Get command here for reference
#Get-CsOnlineDialOutPolicy

$Filename = "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\NATIONAL HEAVY VEHICLE REGULATOR\PR2415-TCO\TCO\NHVR_TCO_WORKINGFILE.csv"

#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
    $upn = $user.UPN
    $outboundpolicy = $user.outboundpolicy
    #Log Users current DialoutPolicy
    Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\temp\Pre-NHVR-DialOutPolicy.csv" -Append -NoTypeInformation
    #Display to screen
    write-host $upn "assigning dial out policy" $outboundpolicy -foregroundcolor Green
    #Set users DialOutpolicy
    Grant-CsDialoutPolicy -id $upn -PolicyName $outboundpolicy
    #Log Users new DialoutPolicy
    Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\temp\Post-NHVR-DialOutPolicy.csv" -Append -NoTypeInformation
    }

Remove-PSSession

Grant-CsDialoutPolicy -PolicyName $outboundpolicy  -Global 

