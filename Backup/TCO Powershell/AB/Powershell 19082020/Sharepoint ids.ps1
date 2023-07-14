$tenant = 'abacusals' #Tenant name at the start of URL
$tenantId = '6682b8c8-95f5-4ebe-9225-076030c1983c' #Tenant ID, can be found in azure AD
$siteName = 'ITTeam' #Sharepoint site name
$docLib = 'Documents' #Sharepoint Document Library

#Install-Module SharePointPnPPowerShellOnline

#Connection
$cred = Get-Credential -UserName $username -Message "Password: $username"
Connect-PnPOnline https://$tenant.sharepoint.com/sites/$siteName -SPOManagementShell

#Convert Tenant ID
$tenantId = $tenantId -replace '-','%2D'

#Convert Site ID
$PnPSite = Get-PnPSite -Includes Id | select id
$PnPSite = $PnPSite.Id -replace '-','%2D'
$PnPSite = '%7B' + $PnPSite + '%7D'

#Convert Web ID
$PnPWeb = Get-PnPWeb -Includes Id | select id
$PnPWeb = $PnPWeb.Id -replace '-','%2D'
$PnPWeb = '%7B' + $PnPWeb + '%7D'

#Convert List ID
$PnPList = Get-PnPList $docLib -Includes Id | select id
$PnPList = $PnPList.Id -replace '-','%2D'
$PnPList = '%7B' + $PnPList + '%7D'
$PnPList = $PnPList.toUpper()

$FULLURL = 'tenantId=' + $tenantId + '&siteId=' + $PnPSite + '&webId=' + $PnPWeb + '&listId=' + $PnPList + '&webUrl=https%3A%2F%2F' + $tenant + '%2Esharepoint%2Ecom%2Fsites%2F' + $siteName + '&version=1'

Write-Output 'List ID: ' $FULLURL