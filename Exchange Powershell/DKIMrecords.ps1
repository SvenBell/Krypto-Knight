#Get all domains from Exchange Online and output CNAME DKIM records

Get-acceptedDomain | ForEach-Object {
    $domain = $_.domainname
    Write-Output $domain

    #get CNAME records for DKIM
    Get-DkimSigningConfig -Identity youremployment.com.au | Format-List Selector1CNAME, Selector2CNAME

}
