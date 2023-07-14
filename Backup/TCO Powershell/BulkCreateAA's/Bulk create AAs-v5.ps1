##############################
# Bulk create Auto Attendants (AAs) for Teams
# v4 Stephen Bell - Now builds from .CSV file handling multiple Resource Accounts per AA
# v5 adds GDAP support - some MS commands need trouble shooting permsisions...
#
##############################

# First connect to correct Tenancy
#Connect-MicrosoftTeams
#Connect-MsolService
#Connect-PartnerCenter

### Functions Section ###
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

Function Pause ($Message = "Press any key to continue...") {
   # Check if running in PowerShell ISE
   If ($psISE) {
      # "ReadKey" not supported in PowerShell ISE.
      # Show MessageBox UI
      $Shell = New-Object -ComObject "WScript.Shell"
      $Button = $Shell.Popup("Click OK to continue.", 0, "Hello", 0)
      Return
   }
 
   $Ignore =
      16,  # Shift (left or right)
      17,  # Ctrl (left or right)
      18,  # Alt (left or right)
      20,  # Caps lock
      91,  # Windows key (left)
      92,  # Windows key (right)
      93,  # Menu key
      144, # Num lock
      145, # Scroll lock
      166, # Back
      167, # Forward
      168, # Refresh
      169, # Stop
      170, # Search
      171, # Favorites
      172, # Start/Home
      173, # Mute
      174, # Volume Down
      175, # Volume Up
      176, # Next Track
      177, # Previous Track
      178, # Stop Media
      179, # Play
      180, # Mail
      181, # Select Media
      182, # Application 1
      183  # Application 2
 
   Write-Host -NoNewline $Message
   While ($KeyInfo.VirtualKeyCode -Eq $Null -Or $Ignore -Contains $KeyInfo.VirtualKeyCode) {
      $KeyInfo = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
   }
}

########################################
# Check these variables
#$domain= "hinchinbrook.onmicrosoft.com" #Best if you use .onmicrosoft.com domain so phone don't die if DNS reg issues
write-host "Preparing..."
Write-host ""
$Filename = "\\tsclient\C\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\IFYS\PR2565-TCO\Project Templates\BulkAACQ.csv"
$TenantID = "e246235b-d301-41f8-b9dd-756c6ac9b294"
#Connect-MicrosoftTeams -TenantId $TenantID
#Connect-MsolService
#Connect-PartnerCenter
$TenantInfo = Get-PartnerCustomer -CustomerId $TenantID
$language = "en-AU"
#$timezone = y"E. Australia Standard Time" # Now in input .csv file

#TimeZone codes
#QLDStandardName               : E. Australia Standard Time
#WAStandardName               : W. Australia Standard Time
#NSW/VIC                    : AUS Eastern Standard Time
########################################
#########################################

write-host "Tenant Name: " $TenantInfo.Name "  Tenant Domain: " $TenantInfo.Domain "  Tenant ID: " $TenantInfo.CustomerID
$confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]"
while($confirmation1 -ne "y")
{
    if ($confirmation1 -eq 'n') {break}
    $confirmation1 = Read-Host "Are you happy with this Tenant? [y/n]"
}

$confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename
while($confirmation2 -ne "y")
{
    if ($confirmation2 -eq 'n') {break}
    $confirmation2 = Read-Host "Are you happy with this file location for the CSV?" $Filename
}

### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    write-host "File import error"
    Break
}

    #Create AutoAttendant and Resource Account
    foreach ($user in $users)
    {

        $AADisplayName = $user.AADisplayName
        $AAName = $user.AAName
        $AATimeZone = $user.AATimeZone
        $RADisplayName = $user.RADisplayName
        $RAUPNPrefix = $user.RAUPNPrefix
        $UPNSuffix = $user.UPNSuffix
        $RAUPN = "$RAUPNPrefix@$UPNSuffix"
        
        if ($AADisplayName -ne "") {
            # Create Auto Attendant
            $MenuOptionAA = New-CsAutoAttendantMenuOption -Action DisconnectCall -DtmfResponse Automatic
            $menuAAQ = New-CsAutoAttendantMenu -Name "$AADisplayName" -MenuOptions @($menuOptionAA)
            $callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ
            New-CsAutoAttendant -Name $AADisplayName -Language $language -TimeZoneId $AATimeZone -DefaultCallFlow $callFlowAAQ
        }

        # Create Resource Account
        $instance = New-CsOnlineApplicationInstance -UserPrincipalName $RAUPN -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $RADisplayName
        
        write-host "Created resource account: " $RADisplayName " " $RAUPN -foregroundcolor Green
        write-host Syncing Resource Account from Azure Active directory
        Sync-CsOnlineApplicationInstance -ObjectId $Instance.ObjectID
    } 

#Pause for 2 minute cause cloud lag
Write-Host 2 minute wait cause cloud lag sucks!
Write-Host "Waiting 2 mins for Cloud sync before linking resource account(s) to AutoAttendant(s)"
Start-Sleep -s 120
#Pause until last Resource Account is showing
(Get-CsOnlineUser $RAUPN).ObjectId
if($? -ne 'false')
{
    while($? -ne 'false')
    {
        Write-Host "Resource Account not found waiting further 20 seconds"
        Start-Sleep -s 20
        (Get-CsOnlineUser $RAUPN).ObjectId
    }
}


#Link Resource account with AutoAttendant
### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    write-host "File import error"
    Break
}

    foreach ($user in $users)
    {
        $AADisplayName = $user.AADisplayName
        $AAName = $user.AAName
        $AATimeZone = $user.AATimeZone
        $RADisplayName = $user.RADisplayName
        $RAUPNPrefix = $user.RAUPNPrefix
        $UPNSuffix = $user.UPNSuffix
        $RAUPN = "$RAUPNPrefix@$UPNSuffix"
        $AADisplayName = $user.AADisplayName

        if ($AADisplayName -ne "") {
        $RAappinstanceid = (Get-CsOnlineUser $RAUPN).Identity
        $AAid = (Get-CsAutoAttendant -NameFilter $AAName | Where-Object Name -eq $AAName).Identity

        write-host "Assigning: " $RADisplayName "Resource account assigned to AA: " $AAName -foregroundcolor Green
        # Associate AutoAttendant and AA Resource account
        New-CsOnlineApplicationInstanceAssociation -Identities $RAappinstanceid -ConfigurationId $AAid -ConfigurationType AutoAttendant

        write-host $RADisplayName "Resource account assigned to AA: " $AAName -foregroundcolor Green
        }
    }


#License Resource account with Virtual User phone system license and set usage location to AU (Australia)

#Finds the virtualusersku name this changes with different tenancies
$virtualusersku = get-MsolAccountSku -TenantId $tenantID | Where-Object {$_.skuPartNumber -contains "PHONESYSTEM_VIRTUALUSER"} | select AccountSkuid

### Import .csv file
Try {
    $users = Import-Csv $FileName
}
Catch {
    write-host "File import error"
    Break
}

    foreach ($user in $users)
    {
        $AADisplayName = $user.AADisplayName
        $AAName = $user.AAName
        $AATimeZone = $user.AATimeZone
        $RADisplayName = $user.RADisplayName
        $RAUPNPrefix = $user.RAUPNPrefix
        $UPNSuffix = $user.UPNSuffix
        $RAUPN = "$RAUPNPrefix@$UPNSuffix"
        $AADisplayName = $user.AADisplayName

        if ($AADisplayName -ne "") {
        $RADisplayName = $user.RADisplayName
        #$upn = GET-MSOLUSER -SEARCHSTRING $displayname | SELECT-OBJECT USERPRINCIPALNAME
        #$RAUPN = Get-msoluser -TenantId $tenantID | Where-Object {$_.Displayname -eq "$RADisplayName"} | select UserprincipalName
        Set-MsolUser -TenantId $tenantID -UserPrincipalName $RAUPN.UserPrincipalName -UsageLocation "AU"
        Set-MsolUserLicense -TenantId $tenantID -UserPrincipalName $RAUPN.UserPrincipalName -AddLicenses $virtualusersku.AccountSkuId -Verbose
        write-host "Assigning" $virtualusersku.AccountSkuId "license to" $RADisplayName $RAUPN.UserPrincipalName -foregroundcolor Green
        }
    } 


#    Disconnect-MicrosoftTeams

