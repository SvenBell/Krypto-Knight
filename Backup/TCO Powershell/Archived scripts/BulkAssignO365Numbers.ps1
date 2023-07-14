#$Credential = Get-Credential
#Import-Module SkypeOnlineConnector
#Connect-MsolService -Credential $Credential
#$sfboSession = New-CsOnlineSession
#Import-PSSession $sfboSession

#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
$Filename = "C:\Temp\users_TCO_Corum.csv"


    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $upn= $user.UPN
        $number= $user.Number
        Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        write-host $upn "assigned" $number -foregroundcolor Green 
    } 

#    Remove-PSSession