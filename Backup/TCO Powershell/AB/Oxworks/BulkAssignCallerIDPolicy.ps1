#After launching a new PowerShell session, connect to Skype for Business Online using the following PowerShell
Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$path = "C:\Users\AndrewBaird\TShopBiz & Entag Group\Projects - Customer Projects\OXWORKS\LD8523- TCO Deployment\TCO project docs\Powershell WORKING files\"
$Filename = $path + "V-DandenongUsers.csv"
#$prelog = $path + "Q3Crestmead-Prelog.csv"
#$postlog = $path + "Q3Crestmead-Postlog.csv"
$callingpolicy = "Dandenong Main Number"


#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        $upn= $user.UPN
        Grant-CsCallingLineIdentity -identity $upn -PolicyName $callingpolicy
        #Display to screen to show progress
        write-host "Assigning caller ID policy to" $upn -ForegroundColor Green
        Write-Host "-------"
    } 
    
   Disconnect-MicrosoftTeams