## DKIM Draft

New-DkimSigningConfig -DomainName sjatkinsplumbing.com.au -KeySize 2048 -Enabled $true

Get-DkimSigningConfig -Identity sjatkinsplumbing.com.au | Format-List Selector1CNAME, Selector2CNAME

#Add 2 x CNAME records for selector1 & Selector2

Set-DkimSigningConfig -Identity sjatkinsplumbing.com.au -Enabled $true

