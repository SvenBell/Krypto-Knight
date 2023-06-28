$Credential = Get-Credential
Import-Module SkypeOnlineConnector
#Install-Module -Name MicrosoftTeams -Force -Allowclobber
#Import-Module MicrosoftTeams
#Install-Module MrAADAdministration
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession


$Filename = "C:\Temp\RTAGenesysuserlist.csv"


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
            $successfulnumber =[PSCustomObject]@{

    'UPN'    = $upn
    'Action' = "Assigned"
    'Number' = $number
    'Error'  = $null
                             }
            $successfulnumber | Export-csv "C:\temp\RTA-Genesys_Phonenumbers.csv" -Append -NoTypeInformation 
        }
        else
        {
            write-host $upn "failed number assignment" $number $Error[0].Exception.Message -foregroundcolor Red
            $failednumber =[PSCustomObject]@{

    'UPN'    = $upn
    'Action' = "failed number assignment"
    'Number' = $number
    'Error'  = $Error[0].Exception.Message
                             }
            $failednumber | Export-csv "C:\temp\RTA-Genesys_Phonenumbers.csv" -Append -NoTypeInformation 
        }
        Grant-CsTeamsCallingPolicy -id $upn -PolicyName $policy
        if ($?)
        {
            write-host $upn "assigned calling policy" $policy -foregroundcolor Cyan
            $successfulpolicy =[PSCustomObject]@{

    'UPN'    = $upn
    'Action' = "assigned calling policy"
    'Policy' = $policy
    'Error'  = $null
                             }
            $successfulpolicy | Export-csv "C:\temp\RTA-Genesys_CallingPolicy.csv" -Append -NoTypeInformation 
        }
        else
        {
            write-host $upn "failed calling policy assignment" $policy $Error[0].Exception.Message -foregroundcolor Red
            $failedpolicy =[PSCustomObject]@{

    'UPN'    = $upn
    'Action' = "failed calling policy assignment"
    'Policy' = $policy
    'Error'  = $Error[0].Exception.Message
                             }
            $failedpolicy | Export-csv "C:\temp\RTA-Genesys_CallingPolicy.csv" -Append -NoTypeInformation  
        }
    } 

    Remove-PSSession $sfboSession
