$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession



$Filename = "C:\Temp\DBCTMuserlistHaypoint.csv"

    $users = Import-Csv $FileName
    Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        #$number= $user.Number
        $oldnumber = $user.OldNumber
        Set-MsolUser -UserPrincipalName $upn -UsageLocation "AU"
        Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $oldnumber 
        Write-Host $upn -foregroundcolor Green
    } 

    Remove-PSSession $sfboSession