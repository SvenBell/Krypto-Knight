#Ref. https://learn.microsoft.com/en-us/powershell/partnercenter/exchange-online-gdap-app?view=partnercenterps-3.0
#variables
$AppId = '<AppID in Partner tenant>'
$AppSecret = '<App secret from AppID in partner tenant>'
$CustomerTenantId = '<Customer tenant ID>'
$consentscope = 'https://api.partnercenter.microsoft.com/user_impersonation'
$AppCredential = (New-Object System.Management.Automation.PSCredential ($AppId, (ConvertTo-SecureString $AppSecret -AsPlainText -Force)))
$PartnerTenantid = '<Partner tenant ID>'
$AppDisplayName = '<App name for AppID in Partner tenant>'
# Get PartnerAccessToken token
$PartnerAccessToken = New-PartnerAccessToken -serviceprincipal -ApplicationId $AppId -Credential $AppCredential -Scopes $consentscope -tenant $PartnerTenantid -UseAuthorizationCode
# Connect using PartnerAccessToken token
$PartnerCenter = Connect-PartnerCenter -AccessToken $PartnerAccessToken.AccessToken
#Grants needed
$MSGraphgrant = New-Object -TypeName Microsoft.Store.PartnerCenter.Models.ApplicationConsents.ApplicationGrant
$MSgraphgrant.EnterpriseApplicationId = "00000003-0000-0000-c000-000000000000"
$MSGraphgrant.Scope = "Directory.Read.All,Directory.AccessAsUser.All"
$ExOgrant = New-Object -TypeName Microsoft.Store.PartnerCenter.Models.ApplicationConsents.ApplicationGrant
$ExOgrant.EnterpriseApplicationID = "00000002-0000-0ff1-ce00-000000000000"
$ExOgrant.Scope = "Exchange.Manage"
New-PartnerCustomerApplicationConsent -ApplicationGrants @($MSGraphgrant, $ExOgrant) -CustomerId $CustomerTenantId -ApplicationId $AppId -DisplayName $appdisplayname
#Connect to customer Exchange via App+User
$token = New-PartnerAccessToken -ApplicationId $AppId -Scopes 'https://outlook.office365.com/.default' -ServicePrincipal -Credential $appcredential -Tenant $CustomerTenantId -RefreshToken $PartnerAccesstoken.refreshToken
Connect-ExchangeOnline -DelegatedOrganization $CustomerTenantId -AccessToken $token.AccessToken