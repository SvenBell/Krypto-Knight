## Import Modules
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

 

while($true){

 

    ## Details
    Clear
    $User = read-host -Prompt "Enter username to disable (eg. JohnS)"
    $DelegatedUser = read-host -Prompt "Enter username to assign mailbox permissions to (eg. JohnS)"
    $UserUPN = $user + "@tshopbiz.com.au"
    $DelegatedUserUPN = $DelegatedUser + "@tshopbiz.com.au"

 

    Write-Host -ForegroundColor Yellow "Processing user: $User"

 

    ## Disable AD account
    Disable-ADAccount -Identity $User

 

    ## Set Mail delegation
    Add-MailboxPermission -Identity $UserUPN -User $DelegatedUserUPN -AccessRights FullAccess -AutoMapping:$true -Confirm:$false
    Add-RecipientPermission -Identity $UserUPN -Trustee $DelegatedUserUPN -AccessRights SendAs -Confirm:$false

 

    ## Set Out Of Office
    Set-MailboxAutoReplyConfiguration -Identity $UserUPN -ExternalAudience:All `
    -InternalMessage "Thank you for your email. <BR><BR> 
    I am currently out of the office for an extended period of time. <BR><BR>

 

    Your email has been redirected and will be responded to as soon as possible. <BR><BR> 
    " `
    -ExternalMessage "Thank you for your email. <BR><BR> 
    I am currently out of the office for an extended period of time. <BR><BR>

 

    Your email has been redirected and will be responded to as soon as possible. <BR><BR> 
    " `
    -AutoReplyState Enabled

 

    Write-Host -ForegroundColor Green "Processing complete: $User"
    pause

 

}