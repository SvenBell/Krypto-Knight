#Bulk create CQ

#$Credential = Get-Credential

# Connect-MicrosoftTeams


#Customise for each customer
########################################
$domain= "hinchinbrook.qld.gov.au"
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\HINCHINBROOK SHIRE COUNCIL\PR2478-TCO\Project Templates\BulkCallQueue.csv"
$language = "en-AU"
$timezone = "E. Australia Standard Time"
#NOTE:
#Conference mode will be turned on
#Allow opt out will be turned on
#TimeZone codes
#QLDStandardName               : E. Australia Standard Time
#WAStandardName               : W. Australia Standard Time
#NSW/VIC                    : AUS Eastern Standard Time
########################################



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



$confirmation = Read-Host "Are you happy with this domain name? [y/n]" $domain
while($confirmation -ne "y")
{
    if ($confirmation -eq 'n') {break}
    $confirmation = Read-Host "Are you happy with this domain name? [y/n]" $domain
}

$confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename
}

    $users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {

        $CQName= $user.callqueue
        #Create Call Queue
        New-CsCallQueue -Name $CQName -UseDefaultMusicOnHold $true -LanguageId $language -AllowOptOut $true -ConferenceMode $true
        #Create Call Queue Resource Account
        New-CsOnlineApplicationInstance -UserPrincipalName $CQName@$domain -ApplicationId 11cd3e2e-fccb-42ad-ad00-878b93575e07 -DisplayName $CQName
        
        write-host $CQName "Created" $CQName@$domain -foregroundcolor Green
        
    } 
    #do until not management object not found for identity
    #Pause for 2 minute cause cloud lag
Write-Host 2 minute wait cause cloud lag sucks!
Write-Host Resource Account Stage
Start-Sleep -s 120

        $users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {
        $CQName= $user.callqueue
        $CQappinstanceid = (Get-CsOnlineUser $CQName@$domain).Identity
        $CQid = (Get-CsCallQueue -NameFilter $CQName).Identity
        #Associate Call Queue and CQ Resource account
        New-CsOnlineApplicationInstanceAssociation -Identities $CQappinstanceid -ConfigurationId $CQid -ConfigurationType CallQueue

        write-host $CQName "assigned Resource account"  -foregroundcolor Green
    }

#    Remove-PSSession $sfboSession



