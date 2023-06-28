$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession

function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}

$Filename = "C:\GitHub\PowerShell\TCO Powershell\BulkAutoAttendant.csv"


    $users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {

        $display= $user.displayname
        #$usertconumber= $user.number
        $language = "en-AU"
        $timezone = "E. Australia Standard Time"
        $domain= "M365x064666.onmicrosoft.com"
        #$userobjectid= (get-csonlineuser $upn).ObjectId
        #$userentity= New-CsAutoAttendantCallableEntity -Identity $userObjectId -Type User
        #AutoAttendant for each user
        $aareceptionQName = "$display"
        $MenuOptionAA = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
        $menuAAQ = New-CsAutoAttendantMenu -Name "$aareceptionQName" -MenuOptions @($menuOptionAA)
        $callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ
        New-CsAutoAttendant -Name $aareceptionQName -Language $language -TimeZoneId $timezone -DefaultCallFlow $callFlowAAQ
        New-CsOnlineApplicationInstance -UserPrincipalName $aareceptionQName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aareceptionQName

        #$aaappinstanceid = (Get-CsOnlineUser $aareceptionQName@$domain).ObjectId
        #$aaid = (Get-CsAutoAttendant -NameFilter $aareceptionQName).Identity

        # Associate AutoAttendant and AA Resource account
        #New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant
        
        write-host $display "Created" $aareceptionQName -foregroundcolor Green
        
    } 

    #Pause for 2 minute cause cloud lag
Write-Host 2 minute wait cause cloud lag sucks!
Write-Host Voicemail Stage
Start-Sleep -s 120

        $users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {
        $display= $user.displayname
        $aareceptionQName = "$display"
        $aaappinstanceid = (Get-CsOnlineUser $aareceptionQName@$domain).ObjectId
        $aaid = (Get-CsAutoAttendant -NameFilter $aareceptionQName).Identity

        # Associate AutoAttendant and AA Resource account
        New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant

        write-host $aareceptionQName "assigned Resource account"  -foregroundcolor Green
    }

    Remove-PSSession $sfboSession



