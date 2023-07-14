cls
 
# This is the username of an Office 365 account with delegated admin permissions
# Install-module -Name PartnerCenter  #May be required
 
# $UserName = "training@gcits.com"
 
#$Cred = get-credential -Credential $UserName
 
#This script is looking for unlicensed Company Administrators (Global Admin). Though you can update the role here to look for another role type.
<#ObjectId                               Name                             Description                                                      
--------                               ----                             -----------                                                      
62e90394-69f5-4237-9190-012177145e10   Company Administrator            Can manage all aspects of Azure AD and Microsoft services that...
95e79109-95c0-4d8e-aee3-d01accf2d47b   Guest Inviter                    Can invite guest users independent of the 'members can invite ...
fe930be7-5e62-47db-91af-98c3a49a38b1   User Administrator               Can manage all aspects of users and groups, including resettin...
729827e3-9c14-49f7-bb1b-9608f156bbb8   Helpdesk Administrator           Can reset passwords for non-administrators and Helpdesk Admini...
f023fd81-a637-4b56-95fd-791ac0226033   Service Support Administrator    Can read service health information and manage support tickets.  
b0f54661-2d74-4c50-afa3-1ec803f12efe   Billing Administrator            Can perform common billing related tasks like updating payment...
4ba39ca4-527c-499a-b93d-d9b492c50246   Partner Tier1 Support            Do not use - not intended for general use.                       
e00e864a-17c5-4a4b-9c06-f5b95a8d5bd8   Partner Tier2 Support            Do not use - not intended for general use.                       
88d8e3e3-8f55-4a1e-953a-9b9898b8876b   Directory Readers                Can read basic directory information. Commonly used to grant d...
9360feb5-f418-4baa-8175-e2a00bac4301   Directory Writers                Can read and write basic directory information. For granting a...
29232cdf-9323-42fd-ade2-1d097af3e4de   Exchange Administrator           Can manage all aspects of the Exchange product.                  
f28a1f50-f6e7-4571-818b-6a12f2af6b6c   SharePoint Administrator         Can manage all aspects of the SharePoint service.                
75941009-915a-4869-abe7-691bff18279e   Skype for Business Administrator Can manage all aspects of the Skype for Business product.        
d405c6df-0af8-4e3b-95e4-4d06e542189e   Device Users                     Device Users                                                     
9f06204d-73c1-4d4c-880a-6edb90606fd8   Azure AD Joined Device Local ... Users assigned to this role are added to the local administrat...
9c094953-4995-41c8-84c8-3ebb9b32c93f   Device Join                      Device Join                                                      
c34f683f-4d5a-4403-affd-6615e00e3a7f   Workplace Device Join            Workplace Device Join                                            
17315797-102d-40b4-93e0-432062caca18   Compliance Administrator         Can read and manage compliance configuration and reports in Az...
d29b2b05-8046-44ba-8758-1e26182fcf32   Directory Synchronization Acc... Only used by Azure AD Connect service.                           
2b499bcd-da44-4968-8aec-78e1674fa64d   Device Managers                  Deprecated - Do Not Use.                                         
9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3   Application Administrator        Can create and manage all aspects of app registrations and ent...
cf1c38e5-3621-4004-a7cb-879624dced7c   Application Developer            Can create application registrations independent of the 'Users...
5d6b6bb7-de71-4623-b4af-96380a352509   Security Reader                  Can read security information and reports in Azure AD and Offi...
194ae4cb-b126-40b2-bd5b-6091b380977d   Security Administrator           Security Administrator allows ability to read and manage secur...
e8611ab8-c189-46e8-94e1-60213ab1f814   Privileged Role Administrator    Can manage role assignments in Azure AD, and all aspects of Pr...
3a2c62db-5318-420d-8d74-23affee5d9d5   Intune Administrator             Can manage all aspects of the Intune product.                    
158c047a-c907-4556-b7ef-446551a6b5f7   Cloud Application Administrator  Can create and manage all aspects of app registrations and ent...
5c4f9dcd-47dc-4cf7-8c9a-9e4207cbfc91   Customer LockBox Access Approver Can approve Microsoft support requests to access customer orga...
44367163-eba1-44c3-98af-f5787879f96a   Dynamics 365 Administrator       Can manage all aspects of the Dynamics 365 product.              
a9ea8996-122f-4c74-9520-8edcd192826c   Power BI Administrator           Can manage all aspects of the Power BI product.                  
b1be1c3e-b65d-4f19-8427-f6fa0d97feb9   Conditional Access Administrator Can manage Conditional Access capabilities.                      
4a5d8f65-41da-4de4-8968-e035b65339cf   Reports Reader                   Can read sign-in and audit reports.                              
790c1fb9-7f7d-4f88-86a1-ef1f95c05c1b   Message Center Reader            Can read messages and updates for their organization in Office...
7495fdc4-34c4-4d15-a289-98788ce399fd   Azure Information Protection ... Can manage all aspects of the Azure Information Protection pro...
38a96431-2bdf-4b4c-8b6e-5d3d8abac1a4   Desktop Analytics Administrator  Can access and manage Desktop management tools and services.     
4d6ac14f-3453-41d0-bef9-a3e0c569773a   License Administrator            Can manage product licenses on users and groups.                 
7698a772-787b-4ac8-901f-60d6b08affd2   Cloud Device Administrator       Full access to manage devices in Azure AD.                       
c4e39bd9-1100-46d3-8c65-fb160da0071f   Authentication Administrator     Allowed to view, set and reset authentication method informati...
7be44c8a-adaf-4e2a-84d6-ab2649e08a13   Privileged Authentication Adm... Allowed to view, set and reset authentication method informati...
baf37b3a-610e-45da-9e62-d9d1e5e8914b   Teams Communications Administ... Can manage calling and meetings features within the Microsoft ...
f70938a0-fc10-4177-9e90-2178f8765737   Teams Communications Support ... Can troubleshoot communications issues within Teams using adva...
fcf91098-03e3-41a9-b5ba-6f0ec8188a12   Teams Communications Support ... Can troubleshoot communications issues within Teams using basi...
69091246-20e8-4a56-aa4d-066075b2a7a8   Teams Administrator              Can manage the Microsoft Teams service.                          
eb1f4a8d-243a-41f0-9fbd-c7cdf6c5ef7c   Insights Administrator           Has administrative access in the Microsoft 365 Insights app.     
ac16e43d-7b2d-40e0-ac05-243ff356ab5b   Message Center Privacy Reader    Can read security messages and updates in Office 365 Message C...
6e591065-9bad-43ed-90f3-e9424366d2f0   External ID User Flow Adminis... Can create and manage all aspects of user flows.                 
0f971eea-41eb-4569-a71e-57bb8a3eff1e   External ID User Flow Attribu... Can create and manage the attribute schema available to all us...
aaf43236-0c0d-4d5f-883a-6955382ac081   B2C IEF Keyset Administrator     Can manage secrets for federation and encryption in the Identi...
3edaf663-341e-4475-9f94-5c398ef6c070   B2C IEF Policy Administrator     Can create and manage trust framework policies in the Identity...
be2f45a1-457d-42af-a067-6ec1fa63bc45   External Identity Provider Ad... Can configure identity providers for use in direct federation.   
e6d1a23a-da11-4be4-9570-befc86d067a7   Compliance Data Administrator    Creates and manages compliance content.                          
5f2222b1-57c3-48ba-8ad5-d4759f1fde6f   Security Operator                Creates and manages security events.                             
74ef975b-6605-40af-a5d2-b9539d836353   Kaizala Administrator            Can manage settings for Microsoft Kaizala.                       
f2ef992c-3afb-46b9-b7cf-a126ee74c451   Global Reader                    Can read everything that a Global Administrator can, but not u...
0964bb5e-9bdb-4d7b-ac29-58e794862a40   Search Administrator             Can create and manage all aspects of Microsoft Search settings.  
8835291a-918c-4fd7-a9ce-faa49f0cf7d9   Search Editor                    Can create and manage the editorial content such as bookmarks,...
966707d0-3269-4727-9be2-8c3a10f19b9d   Password Administrator           Can reset passwords for non-administrators and Password Admini...
644ef478-e28f-4e28-b9dc-3fdde9aa0b1f   Printer Administrator            Can manage all aspects of printers and printer connectors.       
e8cef6f1-e4bd-4ea8-bc07-4b8d950f4477   Printer Technician               Can manage all aspects of printers and printer connectors.       
0526716b-113d-4c15-b2c8-68e3c22b9f80   Authentication Policy Adminis... Can create and manage the authentication methods policy, tenan...
fdd7a751-b60b-444a-984c-02652fe8fa1c   Groups Administrator             Members of this role can create/manage groups, create/manage g...
11648597-926c-4cf3-9c36-bcebb0ba8dcc   Power Platform Administrator     Can create and manage all aspects of Microsoft Dynamics 365, P...
e3973bdf-4987-49ae-837a-ba8e231c7286   Azure DevOps Administrator       Can manage Azure DevOps organization policy and settings.        
8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2   Hybrid Identity Administrator    Can manage AD to Azure AD cloud provisioning, Azure AD Connect...
2b745bdf-0803-4d80-aa65-822c4493daac   Office Apps Administrator        Can manage Office apps cloud services, including policy and se...
d37c8bed-0711-4417-ba38-b4abe66ce4c2   Network Administrator            Can manage network locations and review enterprise network des...
31e939ad-9672-4796-9c2e-873181342d2d   Insights Business Leader         Can view and share dashboards and insights via the M365 Insigh...
3d762c5a-1b6c-493f-843e-55a3b42923d4   Teams Devices Administrator      Can perform management related tasks on Teams certified devices. 
c430b396-e693-46cc-96f3-db01bf8bb62a   Attack Simulation Administrator  Can create and manage all aspects of attack simulation campaigns.
9c6df0f2-1e7c-4dc3-b195-66dfbd24aa8f   Attack Payload Author            Can create attack payloads that an administrator can initiate ...
75934031-6c7e-415a-99d7-48dbd49e875e   Usage Summary Reports Reader     Can see only tenant level aggregates in Microsoft 365 Usage An...
b5a8dcf3-09d5-43a9-a639-8e29ef291470   Knowledge Administrator          Can configure knowledge, learning, and other intelligent featu...
744ec460-397e-42ad-a462-8b3f9747a02c   Knowledge Manager                Has access to topic management dashboard and can manage content. 
8329153b-31d0-4727-b945-745eb3bc5f31   Domain Name Administrator        Can manage domain names in cloud and on-premises.                
8424c6f0-a189-499e-bbd0-26c1753c96d4   Attribute Definition Administ... Define and manage the definition of custom security attributes.  
58a13ea3-c632-46ae-9ee0-9c0d43cd7f3d   Attribute Assignment Administ... Assign custom security attribute keys and values to supported ...
1d336d2c-4ae8-42ef-9711-b3604ce3fc2c   Attribute Definition Reader      Read the definition of custom security attributes.               
ffd52fa5-98dc-465c-991d-fc073eb59f8f   Attribute Assignment Reader      Read custom security attribute keys and values for supported A...
31392ffb-586c-42d1-9346-e59415a2cc4e   Exchange Recipient Administrator Can create or update Exchange Online recipients within the Exc...
45d8d3c5-c802-45c6-b32a-1d70b5e1e86e   Identity Governance Administr... Manage access using Azure AD for identity governance scenarios.  
892c5842-a9a6-463a-8041-72aa08ca3cf6   Cloud App Security Administrator Can manage all aspects of the Cloud App Security product.        
32696413-001a-46ae-978c-ce0f6b3620d2   Windows Update Deployment Adm... Can create and manage all aspects of Windows Update deployment...
11451d60-acb2-45eb-a7d6-43d0f0125c13   Windows 365 Administrator        Can provision and manage all aspects of Cloud PCs.               
3f1acade-1e04-4fbc-9b69-f0302cd84aef   Edge Administrator               Manage all aspects of Microsoft Edge.                            
e300d9e7-4a2b-4295-9eff-f1c78b36cc98   Virtual Visits Administrator     Manage and share Virtual Visits information and metrics from a...
#>
 
$RoleName = "Company Administrator"
 
Connect-MSOLService #-Credential $Cred
 
Import-Module MSOnline
 
$Customers = Get-MsolPartnerContract -All
 
$msolUserResults = @()
 
# This is the path of the exported CSV. You'll need to create a C:\temp folder. You can change this, though you'll need to update the next script with the new path.
 
$msolUserCsv = "C:\temp\AllAdminRolesUserList.csv"
 
 
ForEach ($Customer in $Customers) {
 
    Write-Host "----------------------------------------------------------"
    Write-Host "Getting Unlicensed and licensed Admins for $($Customer.Name)"
    Write-Host " "
 
 
    $CompanyAdminRole = Get-MsolRole | Where-Object{$_.Name -match $RoleName}
    $RoleID = $CompanyAdminRole.ObjectID
    $Admins = Get-MsolRoleMember -TenantId $Customer.TenantId -RoleObjectId $RoleID
    #$Admins = Get-MsolRoleMember -TenantId $Customer.TenantId
    #$Admins = Get-MsolRoleMember -TenantId $Customer.TenantId -all
 
    foreach ($Admin in $Admins){
         
        if($Admin.EmailAddress -ne $null){
 
            $MsolUserDetails = Get-MsolUser -UserPrincipalName $Admin.EmailAddress -TenantId $Customer.TenantId
 
            $LicenseStatus = $MsolUserDetails.IsLicensed
            $userProperties = @{
 
                TenantId = $Customer.TenantID
                CompanyName = $Customer.Name
                PrimaryDomain = $Customer.DefaultDomainName
                DisplayName = $Admin.DisplayName
                EmailAddress = $Admin.EmailAddress
                IsLicensed = $LicenseStatus
                BlockCredential = $MsolUserDetails.BlockCredential
            }
 
            Write-Host "$($Admin.DisplayName) from $($Customer.Name) is an unlicensed Company Admin - BlockCredential: $($MsolUserDetails.BlockCredential)"
 
            $msolUserResults += New-Object psobject -Property $userProperties
             
        }
    }
 
    Write-Host " "
 
}
 
$msolUserResults | Select-Object TenantId,CompanyName,PrimaryDomain,DisplayName,EmailAddress,IsLicensed,BlockCredential | Export-Csv -notypeinformation -Path $msolUserCsv
 
Write-Host "Export Complete"