Import-Module SkypeOnlineConnector
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

####### Modify These variables first ###############
$Filename = "C:\tools\GitHub\PowerShell\TCO Powershell\SJB\BulkAutoAttendant.csv"
$language = "en-AU"
##### Time Zone choices ##### Get-CsAutoAttendantSupportedTimeZone ########
#Id: W. Australia Standard Time     #DisplayName : (UTC+08:00) Perth
#
#Id: Cen. Australia Standard Time   #DisplayName : (UTC+09:30) Adelaide
#
#Id: AUS Central Standard Time      #DisplayName : (UTC+09:30) Darwin
#
#Id: E. Australia Standard Time     #DisplayName : (UTC+10:00) Brisbane
#
#Id: AUS Eastern Standard Time      #DisplayName : (UTC+10:00) Canberra, Melbourne, Sydney
#
#Id: Tasmania Standard Time         #DisplayName : (UTC+10:00) Hobart
###########################################
#$timezone = "Tasmania Standard Time"
#$timezone = "AUS Eastern Standard Time"
#$timezone = "AUS Central Standard Time"
#$timezone = "Cen. Australia Standard Time"
$timezone = "W. Australia Standard Time"
###########################################
$domain= "smrcwa.onmicrosoft.com"
##########################################################################

    $AutoAttendantList = Import-Csv $FileName
    foreach ($AutoAttendant in $AutoAttendantList)
    {
        $AAName= $AutoAttendant.AAName
        $AAResourceName= $AutoAttendant.AAResourceName

        #Create AutoAttendant
        $MenuOptionAA = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
        $menuAAQ = New-CsAutoAttendantMenu -Name "$AAName" -MenuOptions @($menuOptionAA)
        $callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ
        New-CsAutoAttendant -Name $AAname -Language $language -TimeZoneId $timezone -DefaultCallFlow $callFlowAAQ
        write-host "Created Auto-Attendant:" $AAname -foregroundcolor Green

        #Create AA Resource account
        New-CsOnlineApplicationInstance -UserPrincipalName $AAResourceName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $AAResourceName
        write-host "Created Auto-Attendant Resource Account:" $AAResourceName -foregroundcolor Green       
    } 

    #Pause for 2 minute cause cloud lag
Write-Host 2 minute wait to allow cloud to sync - cause cloud lag sucks!
Write-Host Next stage is assigning Resource Accounts to each AA
Start-Sleep -s 120

    $AutoAttendantList = Import-Csv $FileName
    foreach ($AutoAttendant in $AutoAttendantList)
    {
        $AAName= $AutoAttendant.AAName
        $AAResourceName= $AutoAttendant.AAResourceName
        $aaRappinstanceid = (Get-CsOnlineUser $AAResourceName@$domain).ObjectId
        $aaid = (Get-CsAutoAttendant -NameFilter $AAname).Identity

        # Associate AutoAttendant and AA Resource account
        New-CsOnlineApplicationInstanceAssociation -Identities $aaRappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant

        write-host $AAname "assigned Resource account" $AAResourceName -foregroundcolor Green
    }

    Remove-PSSession $sfboSession



