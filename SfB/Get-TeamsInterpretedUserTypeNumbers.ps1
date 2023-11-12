$csonline = Get-CsOnlineUser -ResultSize ([int]::MaxValue)
$csOnline | group AccountType,InterpretedUserType,AccountEnabled -NoElement | sort Name | ft -auto