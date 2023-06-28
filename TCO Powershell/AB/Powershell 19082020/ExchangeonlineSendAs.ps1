Connect-EXOPSSession -UserPrincipalName andrew.baird@entag.com.au

Get-Mailboxpermission andrew.baird@tshopbiz.com.au | ft

Get-RecipientPermission andrew.baird@tshopbiz.com.au | ft

Add-RecipientPermission -id andrew.baird@tshopbiz.com.au -trustee andrew.baird@entag.com.au -AccessRights SendAs

Remove-RecipientPermission -id andrew.baird@tshopbiz.com.au -trustee andrew.baird@entag.com.au -AccessRights SendAs

set-mailbox andrew.baird@tshopbiz.com.au -GrantSendOnBehalfTo andrew.baird@entag.com.au