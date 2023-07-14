## CSV Path
$msolUserCsv = “C:\temp\AllMspAdminAccounts.csv”

## MSP username
#$UserName = “admin@iterrors.com”

## Start script
#$Cred = get-credential #-Credential $UserName
Connect-MSOLService #-Credential $Cred
Import-Module MSOnline

$Customers = Get-MsolPartnerContract -All
$msolUserResults = @()

ForEach ($Customer in $Customers) {

    Write-Host “Getting admin accounts for $($Customer.Name)” -ForegroundColor Yellow
    Write-Host ” ”

    $roles = Get-MsolRole
    foreach ($role in $roles) {

        $Admins = Get-MsolRoleMember -TenantId $Customer.TenantId -RoleObjectId $role.ObjectId

        foreach ($Admin in $Admins){
            if($Admin.EmailAddress -ne $null){
    
                $MsolUserDetails = Get-MsolUser -UserPrincipalName $Admin.EmailAddress -TenantId $Customer.TenantId
                $LicenseStatus = $MsolUserDetails.IsLicensed
                $userProperties = @{

                    CompanyName = $Customer.Name
                    PrimaryDomain = $Customer.DefaultDomainName
                    DisplayName = $Admin.DisplayName
                    EmailAddress = $Admin.EmailAddress
                    IsLicensed = $LicenseStatus
                    AdminRole = $role.Name
                }

                Write-Host “$($Admin.DisplayName) from $($Customer.Name) is a $($role.Name) Admin”

                $msolUserResults += New-Object psobject -Property $userProperties
            }
        }
    }
    Write-Host ” ” 
}

$msolUserResults | Select-Object CompanyName,PrimaryDomain,DisplayName,EmailAddress,IsLicensed,AdminRole | Export-Csv -notypeinformation -Path $msolUserCsv
Write-Host “Export Complete, see $msolUserCsv for the exported file.”