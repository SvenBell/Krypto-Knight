Get-AzureADUserLicenseDetail -UserId "skype.t@scenicrim.qld.gov.au" | Select-Object -ExpandProperty ServicePlans | Where-Object ServicePlanName -eq "TEAMS1"
