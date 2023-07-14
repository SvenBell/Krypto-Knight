$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession



$Filename = "C:\Temp\Cropsmartuserlist_18032020.csv"


    $users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        $number= $user.Number
        #$object = (Get-CsOnlineUser -Identity @($user.UPN)).ObjectId
        #$oldnumber = $user.OldNumber
        Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        write-host $upn "assigned" $number -foregroundcolor Green
        #Set-CsOnlineVoicemailUserSettings -Identity "00000000-0000-0000-0000-000000000000" -DefaultGreetingPromptOverwrite "Hi, I am currently not available." # set to australian english
    } 

    Remove-PSSession $sfboSession

    #Set-CsOnlineVoiceUser -id merc@mercproperty.com.au -TelephoneNumber "61882194750"