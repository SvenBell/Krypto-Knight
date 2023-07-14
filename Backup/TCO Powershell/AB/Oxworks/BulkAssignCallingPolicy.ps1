#After launching a new PowerShell session, connect to Skype for Business Online using the following PowerShell
Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$path = "C:\Users\AndrewBaird\TShopBiz & Entag Group\Projects - Customer Projects\OXWORKS\LD8523- TCO Deployment\TCO project docs\Powershell WORKING files\"
$Filename = $path + "BrendaleUsers.csv"
$prelog = $path + "Brendale-Prelog.csv"
$postlog = $path + "Brendale-Postlog.csv"
$callingpolicy = "Brendale"

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
        Grant-CsTeamsCallingPolicy -identity $upn -PolicyName $callingpolicy
        #Display to screen to show progress

        Write-Host "-------"
    } 
    
   Disconnect-MicrosoftTeams