#16/02/2022 Andrew Baird
#Reach out if there are any issues or refinements needed

Connect-MsolService

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, DisplayName, FirstName, UPN and pw are needed
#Generate bulk passwords to csv from here https://manytools.org/network/password-generator/
#
##########################################################
#Variables to be changed to suit each customer
$path = "C:\Users\AndrewBaird\Entag Group\Projects - Customer Projects\Sunshine Coast Council\0. SSC - TELECOMMUNICATIONS PROJECT\Streams\TCO\"
$File = "CommonArea-D-Libraries.csv"

##########################################################
$Filename = $path+$file    
#
#
    $users = Import-Csv $FileName
    foreach ($user in $users)
    {
        $upn= $user.UPN
        $DisplayName= $user.DisplayName
        $FirstName= $user.FirstName
        $pw= $user.pw
        New-msoluser -UserPrincipalName $upn -DisplayName $displayName -FirstName $FirstName -Password $pw -UsageLocation AU
        Write-host $DisplayName "Created" -ForegroundColor Green
        }



