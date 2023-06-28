$Credential = Get-Credential
Import-Module SkypeOnlineConnector
Connect-MsolService -Credential $Credential
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession


$user=
$number=
$usertconumber=


$Filename = "C:\Temp\Mercuserlist_17062020B.csv"


    $users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {
        $upn = $user.upn
        $display= $user.displayname
        $usertconumber= $user.number
        $language = "en-AU"
        $timezone = "E. Australia Standard Time"
        $domain= "mercproperty.com.au"
        $userobjectid= (get-csonlineuser $upn).ObjectId
        $userentity= New-CsAutoAttendantCallableEntity -Identity $userObjectId -Type User
        #AutoAttendant for each user
        $aareceptionQName = "AA-$display"
        $MenuOptionAA = New-CsAutoAttendantMenuOption -Action TransferCallToTarget -DtmfResponse Automatic -CallTarget $userentity
        $menuAAQ = New-CsAutoAttendantMenu -Name "$aareceptionQName" -MenuOptions @($menuOptionAA)
        $callFlowAAQ = New-CsAutoAttendantCallFlow -Name "DefaultAAQ" -Menu $menuAAQ
        New-CsAutoAttendant -Name $aareceptionQName -Language $language -TimeZoneId $timezone -DefaultCallFlow $callFlowAAQ
        New-CsOnlineApplicationInstance -UserPrincipalName $aareceptionQName@$domain -ApplicationId ce933385-9390-45d1-9512-c8d228074e07 -DisplayName $aareceptionQName

        
        write-host $upn "Created" $aareceptionQName -foregroundcolor Green
        
    } 

    Remove-PSSession $sfboSession



