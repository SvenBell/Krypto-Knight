Import-Module Az

Connect-AzAccount

Get-AzSubscription
Set-AzContext -Subscription "Subscription ID"

#applies standard template MSP policies
New-AzDeployment -Name EntagMSP -Location "Australiaeast" -TemplateFile "C:\Users\BrytonWishart\TShopBiz & Entag Group\Managed Services - General\PowerShell\Azure Lighthouse Onboarding/MSP-AzureOffer.json" -TemplateParameterFile "C:\Users\BrytonWishart\TShopBiz & Entag Group\Managed Services - General\PowerShell\Azure Lighthouse Onboarding/MSP-AzureOffer-Param.json" -Verbose

