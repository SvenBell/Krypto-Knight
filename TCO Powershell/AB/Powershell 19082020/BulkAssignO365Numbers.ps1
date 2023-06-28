
#Filename is the csv with user list heading UPN
#Heading UPN and Number are needed, if the number is blank it should remove the number from the user.
$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession



$Filename = "C:\Temp\DASSuserlist.csv"


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


    Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number



    #Get-CsOnlineTelephoneNumber | ft | export-csv C:\temp\NCPHNPhonemumberexport4.csv
    #Get-CsOnlineTelephoneNumber -ResultSize 3000 | select FriendlyName,Id,activationstate,InventoryType,citycode,location,O365Region,UserId | export-csv C:\temp\NCPHNPhonenumberexport5.csv 


    #Get-CsOnlineTelephoneNumber -isnotassigned -TelephoneNumberStartsWith '617558' | ft