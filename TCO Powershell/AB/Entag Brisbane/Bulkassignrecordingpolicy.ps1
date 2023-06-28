#After launching a new PowerShell session, connect to Skype for Business Online using the following PowerShell
Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
#CHANGE BELOW VARIABLES FOR EACH CUSTOMER
##############################################################################
$path = "C:\Users\AndrewBaird\TShopBiz & Entag Group\ENTAG Connect - Documents\Customers\ENTAG Group\TCO\Entag Office move\Brisbane\"
$File = "testrecording.csv"
$recordingpolicy = “RecordingPolicyClobba”
##############################################################################
$Filename = $path+$file



#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        $upn= $user.UPN
        #Assigning recording policy to each user
        Grant-CsTeamsComplianceRecordingPolicy -Identity $upn -PolicyName $recordingpolicy
        #Display to screen
        write-host $upn "assigned" $recordingpolicy -foregroundcolor Green 
    } 

Write-host "Users with policy applied"
Get-CsOnlineUser | Where-Object {$_.TeamsComplianceRecordingPolicy -eq “RecordingPolicyClobba”} | Select UserPrincipalName


Disconnect-MicrosoftTeams
