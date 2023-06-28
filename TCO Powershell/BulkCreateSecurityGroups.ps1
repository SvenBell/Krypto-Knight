Connect-MsolService

#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$Filename = "C:\Temp\oxworks-SGs.csv"

#Import data from CSV file into $users variable as a table
    $groups = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($group in $groups)
    {

    #Set $groupname variable to equal group name
    $groupname= $group.groupname

    New-msolGroup -DisplayName $groupname
    }

