$Credential = Get-Credential
Import-Module SkypeOnlineConnector
#Install-Module -Name MicrosoftTeams -Force -Allowclobber
#Import-Module MicrosoftTeams
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession


$Filename = "C:\Temp\AB_calling.csv"


    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $upn= $user.UPN
        $number= $user.Number
        $policy= $user.callingpolicy
        $ErrorActionPreference = 'SilentlyContinue'

        Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        if ($?)
        {
            write-host $upn "assigned" $number -foregroundcolor Green
        }
        else
        {
            write-host $upn "failed number assignment" $Error[0].Exception.Message -foregroundcolor Red
        }
        Grant-CsTeamsCallingPolicy -id $upn -PolicyName $policy
        if ($?)
        {
            write-host $upn "assigned calling policy" $policy -foregroundcolor Cyan
        }
        else
        {
            write-host $upn "failed calling policy assignment" $Error[0].Exception.Message -foregroundcolor Red
        }
    } 

    Remove-PSSession $sfboSession
