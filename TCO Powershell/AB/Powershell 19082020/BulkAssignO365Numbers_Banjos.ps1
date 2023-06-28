$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession



$Filename = "C:\Temp\Banjosuserlist_29012020.csv"


    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        #$number= $user.Number
        $oldnumber = $user.OldNumber
        Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $oldnumber 
    } 

    Remove-PSSession $sfboSession