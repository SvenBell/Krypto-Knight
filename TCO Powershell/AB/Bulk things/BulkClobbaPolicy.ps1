#After launching a new PowerShell session, connect to Skype for Business Online using the following PowerShell
Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$Filename = "C:\Temp\Clobba\Remove-Users-24022022.csv"
#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        #$upn= $user.UPN
        $upn = "nick.friske@tbtcqldcentralsunshinecoast.com.au"
        #$upn = "kirsty.lavender@tbtcbrisbanecity.com.au"
        #$upn = "jackson.spender@tbtcqldcentralsunshinecoast.com.au"
        #$upn = "sam.stolberg@tbtcqldcentralsunshinecoast.com.au"
        #$upn = "Liam.Belletty@tbtcqldcentralsunshinecoast.com.au"
        #$upn = "mikaela.templeton@tbtcbrisbanecity.com.au"
        #$upn = "1b5618e44121489182f9296ced968e5akirsty.lavender@tbtcbrisbanecity.com.au"
        #Set $name variable to equal Users name
        Grant-CsTeamsComplianceRecordingPolicy -Identity $upn -PolicyName "RecordingPolicyClobba"
        Re
        #Grant-CsTeamsComplianceRecordingPolicy -Identity $upn -PolicyName $null
        Write-Host "Adding RecordingPolicyClobba to" $upn
        Write-Host "-------"
    } 
    
    Disconnect-MicrosoftTeams


    #Get-CsOnlineUser | Where-Object {$_.TeamsComplianceRecordingPolicy -eq "RecordingPolicyClobba"} | Select UserPrincipalName
    #Get-CsOnlineUser | Where-Object {$_.TeamsComplianceRecordingPolicy -eq "Global"} | Select UserPrincipalName
    #Get-CsTeamsComplianceRecordingPolicy
    
    ####New command
    #Get-csonlineuser -filter "TeamsComplianceRecordingPolicy -eq 'RecordingPolicyClobba'" | Select UserPrincipalName

    #Get-CsOnlineUser -Identity $upn