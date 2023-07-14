
Connect-MicrosoftTeams


#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\ENTAG-User-numbers.csv"

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
        #$name= $user.Name
        #Log current users license status to pre change log file
        $displayname = Get-CsOnlineuser -identity $upn | Select DisplayName
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv "C:\tools\temp\omnii-Phone.csv" -Append -NoTypeInformation
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        #Dislay to screen
        write-host $upn "assigning" $number -foregroundcolor Green 
        #Update the users Teams phone number
        ##Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        # WARNING: It can take 1-2 minutes for details to change in back end
        #Log current users license status to post change log file
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv "C:\tools\temp\omnii-Phone.csv" -Append -NoTypeInformation
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        #Write-Host "-------"
    } 