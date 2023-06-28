Import-Module ActiveDirectory

$users = Import-CSV c:\temp\users.csv

foreach ($user in $users){
Set-ADUSer -GivenName $_.FirstName -Surname $_.Lastname -EmailAddress $_.Email -Office $_.Office -TelephoneNumber $_.Telephone -MobilePhone $_.Mobile -StreetAddress $_.StreetAddress -City $_.City -State $_.State -PostalCode $_.Postcode -Title $_.Title}



