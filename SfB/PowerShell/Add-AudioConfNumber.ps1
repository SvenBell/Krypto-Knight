<#
Account                         Environment Tenant                               TenantId                            
-------                         ----------- ------                               --------                            
a_stephenb@scenicrim.qld.gov.au AzureCloud  a2b76b3b-b366-4f97-8997-31aee9bc8618 a2b76b3b-b366-4f97-8997-31aee9bc8618

#>

Get-CsOnlineDialInConferencingBridge

<#
Identity             : d8dec4e1-aee8-4e57-b8ba-948e8de3e8a9
Name                 : Conference Bridge
Region               : APAC
DefaultServiceNumber : 61272084711
IsDefault            : True
ServiceNumbers       : {61272084711, 864009196442, 85230086066, 912262590655...}
#>

$b = Get-CsOnlineDialInConferencingBridge

Register-csOnlineDialInConferencingServiceNumber -identity 61755405959 -BridgeId $b.identity
<# Register-csOnlineDialInConferencingServiceNumber : The specified number is not a number capable of being assigned to Audio Conferencing. Please select a Service Number to register to the 
bridge. https://learn.microsoft.com/en-us/microsoftteams/manage-phone-numbers-landing-page#service-telephone-numbers
At line:1 char:1
+ Register-csOnlineDialInConferencingServiceNumber -identity 6175540595 ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: ({ Identity = 61...BridgeName =  }:<>f__AnonymousType89`3) [Register-CsOnli...ngServiceNumber], Exception
    + FullyQualifiedErrorId : Forbidden,Microsoft.Teams.ConfigApi.Cmdlets.RegisterCsOnlineDialInConferencingServiceNumber
#>