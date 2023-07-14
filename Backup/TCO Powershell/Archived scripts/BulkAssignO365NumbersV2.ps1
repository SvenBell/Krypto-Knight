#After launching a new PowerShell session, connect to Skype for Business Online using the following PowerShell
Import-Module SkypeOnlineConnector
$Session = New-CsOnlineSession
Import-PSSession $Session  

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$Filename = "C:\tools\Temp\omnii.csv"

#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        $upn= $user.UPN
        #Set $number variable to equal Users phone number
        $number= $user.Number
        #Set $name variable to equal Users name
        $name= $user.Name
        #Log current users license status to pre change log file
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv "C:\tools\temp\omnii-Phone.csv" -Append -NoTypeInformation
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        #Dislay to screen
        write-host $name $upn "assigning" $number -foregroundcolor Green 
        #Update the users Teams phone number
        Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        # WARNING: It can take 1-2 minutes for details to change in back end
        #Log current users license status to post change log file
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv "C:\tools\temp\omnii-Phone.csv" -Append -NoTypeInformation
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        Write-Host "-------"
    } 
    
    Remove-PSSession

    #Connect-MicrosoftTeams
    #Get-CsUserPolicyAssignment -Identity $upn
    #Get-CsUserPolicyAssignment -Identity $upn -PolicyType TenantDialPlan
    ###
    #Grant-Cs<PolicyName> -Identity <User Identity> -PolicyName $null
    #AU-QLD-07
    #AU-VIC-TAS-03
    #AU-SA-WA-NT-08
    #AU-NSW-ACT-02
    #
    #Grant-CsTenantDialPlan -Identity $upn -PolicyName AU-NSW-ACT-02


    #Filename is the csv with user list heading UPN
    #CSV file requires first line to have Heading Name, UPN and Number are needed, 
    #if the number is blank it should remove the number from the user.
    $Filename = "C:\tools\Temp\omnii.csv"

    Connect-MicrosoftTeams

    #Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        $upn= $user.UPN
        #Set $number variable to equal Users phone number
        $number= $user.Number
        #Set $name variable to equal Users name
        $name= $user.Name
        #Set $state caiable to equal users State
        $state= $user.State
        #Log current users license status to pre change log file
        Get-CsUserPolicyAssignment -Identity $upn -PolicyType TenantDialPlan | export-csv "C:\tools\temp\omnii-DialPlan.csv" -Append -NoTypeInformation
        Get-CsUserPolicyAssignment -Identity $upn -PolicyType TenantDialPlan
        #Dislay to screen
        write-host $name $upn "Assigning Dial Plan" $state -foregroundcolor Green 
        #Update the users Teams phone number
        If ($state -like 'QLD*') {
        Grant-CsTenantDialPlan -Identity $upn -PolicyName AU-QLD-07
        Grant-CsCallingLineIdentity -Identity $upn -PolicyName OMNII-QLD
        } ElseIf ($state -like 'NSW*') {
        Grant-CsTenantDialPlan -Identity $upn -PolicyName AU-NSW-ACT-02
        Grant-CsCallingLineIdentity -Identity $upn -PolicyName OMNII-NSW
        } ElseIf ($state -like 'VIC*') {
        Grant-CsTenantDialPlan -Identity $upn -PolicyName AU-VIC-TAS-03
        Grant-CsCallingLineIdentity -Identity $upn -PolicyName OMNII-VIC
        } ElseIf ($state -like 'SA*') {
        Grant-CsTenantDialPlan -Identity $upn -PolicyName AU-SA-WA-NT-08
        #Grant-CsCallingLineIdentity -Identity $upn -PolicyName OMNII-SA
        } ElseIf ($state -like 'WA*') {
        Grant-CsTenantDialPlan -Identity $upn -PolicyName AU-SA-WA-NT-08
        #Grant-CsCallingLineIdentity -Identity $upn -PolicyName OMNII-WA
        } ElseIf ($state -like 'NT*') {
        Grant-CsTenantDialPlan -Identity $upn -PolicyName AU-SA-WA-NT-08
        #Grant-CsCallingLineIdentity -Identity $upn -PolicyName OMNII-NT
        } Else {write-host $name $upn "State missing" -foregroundcolor Red
        }
        # WARNING: It can take 1-2 minutes for details to change in back end
        #Log current users license status to post change log file
        Get-CsUserPolicyAssignment -Identity $upn -PolicyType TenantDialPlan | export-csv "C:\tools\temp\omnii-DialPlan.csv" -Append -NoTypeInformation
        Get-CsUserPolicyAssignment -Identity $upn -PolicyType TenantDialPlan
        Write-Host "-------"
    } 