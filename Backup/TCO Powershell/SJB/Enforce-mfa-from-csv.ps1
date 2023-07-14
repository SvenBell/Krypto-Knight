Write-Host "RUNNING SCRIPT"
Write-Host "Authenticating MsolService"

Connect-MsolService

Write-Host ""
Write-Host "Importing user list from csv file..."
Write-Host ""
  
$users = Import-Csv C:\tools\Users\csv\enablemfa.csv

Write-Host "Checking user list..."
Write-Host ""

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

foreach ($user in $users)
  
{

    Get-MsolUser | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | FT -AutoSize
    Get-MsolUser | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | export-csv "C:\tools\temp\Pre-MFA-Log.csv" -Append -NoTypeInformation
     
    #Get-MsolUser -UserPrincipalName $user.UserPrincipalName | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | FT -AutoSize
    #Get-MsolUser -UserPrincipalName $user.UserPrincipalName | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | export-csv "C:\tools\temp\Pre-MFA-Log.csv" -Append -NoTypeInformation
    
}
  
   
Read-Host -Prompt "Press Enter to Enforce MFA to all users in list"
foreach ($user in $users)
  
{
 
    $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
 
    $st.RelyingParty = "*"
 
    #$st.State = "Enabled"
    $st.State = "Enforced"
 
    $sta = @($st)
    #Get-MsolUser -UserPrincipalName $user.UserPrincipalName | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | FT -AutoSize
    #Get-MsolUser -UserPrincipalName $user.UserPrincipalName | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | export-csv "C:\tools\temp\Pre-MFA-Log.csv" -Append -NoTypeInformation
    #Display to screen
    write-host $user.UserPrincipalName "Setting MFA Status to enforced" -foregroundcolor Green
    Set-MsolUser -UserPrincipalName $user.UserPrincipalName -StrongAuthenticationRequirements $sta

}
  
Write-Host ""
Write-Host "Waiting 25 seconds to check new MFA status..."
Start-Sleep -s 25
write-host "" -foregroundcolor Green
write-host "Generating MFA Update Report Results"
  
foreach ($user in $users)
  
{
 
    Get-MsolUser -UserPrincipalName $user.UserPrincipalName | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | FT -AutoSize
    Get-MsolUser -UserPrincipalName $user.UserPrincipalName | select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | export-csv "C:\tools\temp\Post-MFA-Log.csv" -Append -NoTypeInformation
    
}
  


Write-Host ""
Write-Host "DONE RUNNING SCRIPT"
  
Read-Host -Prompt "Press Enter to exit"