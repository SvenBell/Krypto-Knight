$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession



$Filename = "C:\Temp\Cropsmartuserlist_11022020.csv"


    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        Set-CsUser -Identity $upn -EnterpriseVoiceEnabled $true # | Export-csv "C:\temp\Cropsmart_EnabledVoice.csv" -Append -NoTypeInformation
        Write-Host $upn -foregroundcolor Green
    } 

    Remove-PSSession $sfboSession

