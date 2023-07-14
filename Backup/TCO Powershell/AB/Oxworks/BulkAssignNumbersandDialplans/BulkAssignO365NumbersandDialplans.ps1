#After launching a new PowerShell session, connect to Skype for Business Online using the following PowerShell
Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$path = "C:\Users\AndrewBaird\TShopBiz & Entag Group\Projects - Customer Projects\OXWORKS\LD8523- TCO Deployment\TCO project docs\Powershell WORKING files\"
$Filename = $path + "V-CampbellfieldUsers.csv"
$prelog = $path + "V-CampbellfieldUsers-Prelog.csv"
$postlog = $path + "V-CampbellfieldUsers-Postlog.csv"
$state = "VIC"
Switch ($state)
        {
        QLD {
        #Setting dialplan null for global
        $dialplan = ""
        }
        NSW {
        #Setting dialplan name for NSW
        $dialplan = "AU-NSW-ACT-02"
        }
        VIC {
        #Setting dialplan name for VIC
        $dialplan = "AU-VIC-TAS-03"
        }
        TAS {
        #Setting dialplan name for TAS
        $dialplan = "AU-VIC-TAS-03"
        }
        SA {
        #Setting dialplan name for SA
        $dialplan = "AU-SA-WA-NT-08"
        }
        WA {
        #Setting dialplan name for WA
        $dialplan = "AU-SA-WA-NT-08"
        }
        NT {
        #Setting dialplan name for NT
        $dialplan = "AU-SA-WA-NT-08"
        }
        ACT {
        #Setting dialplan name for ACT
        $dialplan = "AU-NSW-ACT-02"
        }
        Default{}
        }

#List of dialplan, Global is set to QLD
    #AU-VIC-TAS-03
    #AU-SA-WA-NT-08
    #AU-NSW-ACT-02
#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        $upn= $user.UPN
        #Set $number variable to equal Users phone number
        $number= $user.tconumber
        #Set $name variable to equal Users name
        $name= Get-CsOnlineUser -identity $upn | Select DisplayName
        #Display to screen to show progress
        write-host $name.DisplayName $upn "logging phone number"
        #Log current users license status to pre change log file
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv $prelog -Append -NoTypeInformation
        #Display to screen
        write-host $name.DisplayName $upn "assigning" $number -foregroundcolor Green 
        #Update the users Teams phone number
        Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        #Display to screen to show progress
        write-host $name.DisplayName $upn "logging dialplan" -ForegroundColor Cyan
        #Log current users dialplan
        Get-CsUserPolicyAssignment -Identity $upn -PolicyType TenantDialPlan | export-csv $prelog -Append -NoTypeInformation
        #Display to screen
        write-host $name.DisplayName $upn "assigning dialplan" $dialplan
        #Set Dialplan for current user
        Grant-CsTenantDialPlan -Identity $upn -PolicyName $dialplan
        # WARNING: It can take 1-2 minutes for details to change in back end
        #Log current users license status to post change log file
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv $postlog -Append -NoTypeInformation
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        Write-Host "-------"
    } 
    
   Disconnect-MicrosoftTeams
