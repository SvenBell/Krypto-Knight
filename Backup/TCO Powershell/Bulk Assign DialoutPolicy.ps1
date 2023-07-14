
Connect-MicrosoftTeams
#Get command here for reference
#Get-CsOnlineDialOutPolicy

#.csv file require minimum two columns, one headed: UPN   the other headed: outbound
#the list user upns to set and corressponding DoialOut policy indentites below the headers
$Filename = "C:\Users\StephenBell_mw03ceg\TShopBiz & Entag Group\Projects - Customer Projects\Board of Professional Engineers\PR2513-TCO\Project Templates\NumberAssignments.csv"

#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
    $upn = $user.UPN
    $outboundpolicy = $user.outbound
    #Log Users current DialoutPolicy
    Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\tools\temp\Pre-BPEQ-DialOutPolicy.csv" -Append -NoTypeInformation
    #Display to screen
    write-host $upn "assigning dial out policy" $outboundpolicy -foregroundcolor Green
    #Set users DialOutpolicy
    Grant-CsDialoutPolicy -id $upn -PolicyName $outboundpolicy
    #Log Users new DialoutPolicy
    Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy | export-csv "C:\tools\temp\Post-BPEQ-DialOutPolicy.csv" -Append -NoTypeInformation
    }

Remove-PSSession


#Set the policy on the tenant level with the following cmdlet.
#
#PowerShell#
#
#Get-CsOnlineDialOutPolicy
#Grant-CsDialoutPolicy -PolicyName <policy name>  -Global 
#Grant-CsDialoutPolicy -PolicyName DialoutCPCInternationalPSTNDomestic  -Global 
#Get-CsOnlineUser -identity $upn | select DisplayName,UserPrincipalName,OnlineDialOutPolicy
#All users of the tenant who don't have any dialout policy assigned will get this policy. Other users remain with their current policy.

#PS C:\WINDOWS\system32> Get-CsOnlineDialOutPolicy

#
#Identity                         : Global
#AllowPSTNConferencingDialOutType : InternationalAndDomestic
#AllowPSTNOutboundCallingType     : InternationalAndDomestic
#
#Identity                         : Tag:DialoutCPCandPSTNInternational
#AllowPSTNConferencingDialOutType : InternationalAndDomestic
#AllowPSTNOutboundCallingType     : InternationalAndDomestic
#
#Identity                         : Tag:DialoutCPCDomesticPSTNInternational
#AllowPSTNConferencingDialOutType : DomesticOnly
#AllowPSTNOutboundCallingType     : InternationalAndDomestic
#
#Identity                         : Tag:DialoutCPCDisabledPSTNInternational#
#AllowPSTNConferencingDialOutType : Disabled
#AllowPSTNOutboundCallingType     : InternationalAndDomestic
#
#Identity                         : Tag:DialoutCPCInternationalPSTNDomestic
#AllowPSTNConferencingDialOutType : InternationalAndDomestic
#AllowPSTNOutboundCallingType     : DomesticOnly
#
#Identity                         : Tag:DialoutCPCInternationalPSTNDisabled
#AllowPSTNConferencingDialOutType : InternationalAndDomestic
#AllowPSTNOutboundCallingType     : Disabled
#
#Identity                         : Tag:DialoutCPCandPSTNDomestic
#AllowPSTNConferencingDialOutType : DomesticOnly
#AllowPSTNOutboundCallingType     : DomesticOnly
#
#Identity                         : Tag:DialoutCPCDomesticPSTNDisabled
#AllowPSTNConferencingDialOutType : DomesticOnly
#AllowPSTNOutboundCallingType     : Disabled
#
#Identity                         : Tag:DialoutCPCDisabledPSTNDomestic
#AllowPSTNConferencingDialOutType : Disabled
#AllowPSTNOutboundCallingType     : DomesticOnly
#
#Identity                         : Tag:DialoutCPCandPSTNDisabled
#AllowPSTNConferencingDialOutType : Disabled
#AllowPSTNOutboundCallingType     : Disabled
#
#Identity                         : Tag:DialoutCPCZoneAPSTNInternational
#AllowPSTNConferencingDialOutType : ZoneA
#AllowPSTNOutboundCallingType     : InternationalAndDomestic
#
#Identity                         : Tag:DialoutCPCZoneAPSTNDomestic
#AllowPSTNConferencingDialOutType : ZoneA
#AllowPSTNOutboundCallingType     : DomesticOnly
#
#Identity                         : Tag:DialoutCPCZoneAPSTNDisabled
#AllowPSTNConferencingDialOutType : ZoneA
#AllowPSTNOutboundCallingType     : Disabled
#