#After launching a new PowerShell session, connect to Skype for Business Online using the following PowerShell
Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
#CHANGE BELOW VARIABLES FOR EACH CUSTOMER
##############################################################################
$path = "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\Sunshine Coast Council\0. SSC - TELECOMMUNICATIONS PROJECT\Streams\TCO\CoolumLibrary\"
$File = "Coolumlibrary-Users.csv"
$export = "Coolumlibrary-Users-16032022"
##############################################################################
$Filename = $path+$file
$exportprename = $path+$export+'-pre.csv'
$exportpostname = $path+$export+'-post.csv'

#Function for pause progress bar
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


#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        $upn= $user.UPN
        #Set $number variable to equal Users phone number
        $number= $user.tiptNumber
        #Set $name variable to equal Users name
        #$migratingnumber = $user.migratingnumber
        $name= Get-CsOnlineUser -identity $upn | Select DisplayName
        #Log current users license status to pre change log file
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv $exportprename -Append -NoTypeInformation
        Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        #Display to screen
        write-host $name.DisplayName $upn "assigning" $number -foregroundcolor Green 
        #Update the users Teams phone number change to $migratingnumber when needed
        #Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        Set-CsPhoneNumberAssignment -id $upn -phonenumber $number -phonenumbertype CallingPlan
        
    } 

Write-Host 30 second pause waiting for Line URI field to populate
Start-Sleep -s 30

   # Seperate foreach loop as URI field takes a little longer to populate
   
   foreach ($user in $users)
    { 
    $upn= $user.UPN
    # WARNING: It can take 1-2 minutes for details to change in back end
    #Log current users license status to post change log file
    Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv $exportpostname -Append -NoTypeInformation
    Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
    Write-Host "-------"
    }

Disconnect-MicrosoftTeams

