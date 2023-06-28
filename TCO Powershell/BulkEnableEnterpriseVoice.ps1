$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession



$Filename = "C:\Temp\MercUserlist_05022020.csv"


    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        Set-CsUser -Identity $upn -EnterpriseVoiceEnabled $true 
    } 

    Remove-PSSession $sfboSession

