##############################
# Bulk create Autoattendants for Teams
##############################

#Connect-MicrosoftTeams

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

########################################
#Check these variables
$domain= "hinchinbrook.onmicrosoft.com"
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\HINCHINBROOK SHIRE COUNCIL\PR2478-TCO\Project Templates\BulkAA.csv"


#########################################
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
    #Create AutoAttendant and Resource Account
    foreach ($user in $users)
    {

        $display= $user.displayname
        $language = "en-AU"
        $timezone = "E. Australia Standard Time"
        $aareceptionQName = "$display"
        $MenuOptionAA = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
        $menuAAQ = New-CsAutoAttendantMenu -Name "$aareceptionQName" -MenuOptions @($menuOptionAA)
        $callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ
        New-CsAutoAttendant -Name $aareceptionQName -Language $language -TimeZoneId $timezone -DefaultCallFlow $callFlowAAQ
        $instance = New-CsOnlineApplicationInstance -UserPrincipalName $aareceptionQName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aareceptionQName
        
        write-host $display "Created" $aareceptionQName -foregroundcolor Green
        write-host Syncing Resource Account from Azure Active directory
        Sync-CsOnlineApplicationInstance -ObjectId $Instance.ObjectID
    } 

    #Pause for 2 minute cause cloud lag
Write-Host 2 minute wait cause cloud lag sucks!
Write-Host "Waiting for account sync before linking resource account to AutoAttendant"
Start-Sleep -s 120
#Pause until last Resource Account is showing
(Get-CsOnlineUser $aareceptionQName@$domain).ObjectId
if($? -ne 'false')
{
    while($? -ne 'false')
    {
        Write-Host "Resource Account not found waiting 30 seconds"
        Start-Sleep -s 20
        (Get-CsOnlineUser $aareceptionQName@$domain).ObjectId
    }
}


#Link Resource account with AutoAttendant
        $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $display = $user.displayname
        $aareceptionQName = "$display"
        $aaappinstanceid = (Get-CsOnlineUser $aareceptionQName@$domain).Identity
        $aaid = (Get-CsAutoAttendant -NameFilter $aareceptionQName).Identity

        # Associate AutoAttendant and AA Resource account
        New-CsOnlineApplicationInstanceAssociation -Identities $aaappinstanceid -ConfigurationId $aaid -ConfigurationType AutoAttendant

        write-host $aareceptionQName "assigned Resource account"  -foregroundcolor Green
    }

#License Resource account with Virtual User phone system license

#$credentials = Get-Credential
#install-module msonline -force
#import-module Msonline -UseWindowsPowerShell
#Import-Module AzureAD -UseWindowsPowerShell
Connect-MsolService #-Credential $credentials
#Finds the virtualusersku name this changes with different tenancies
$virtualusersku = get-MsolAccountSku | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"} | select AccountSkuid



    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $displayname = $user.displayname
        #$upn = GET-MSOLUSER -SEARCHSTRING $displayname | SELECT-OBJECT USERPRINCIPALNAME
        $upn = Get-msoluser | Where-Object {$_.Displayname -eq "$displayname"} | select UserprincipalName
        Set-MsolUser -UserPrincipalName $upn.UserPrincipalName -UsageLocation "AU"
        Set-MsolUserLicense -UserPrincipalName $upn.UserPrincipalName -AddLicenses $virtualusersku.AccountSkuId -Verbose
        write-host "Assigning" $virtualusersku.AccountSkuId "license to" $displayname $upn.UserPrincipalName -foregroundcolor Green
    } 



#    Disconnect-MicrosoftTeams



