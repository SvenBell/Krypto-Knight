﻿#Connect to Microsoft Teams Module
Connect-MicrosoftTeams
#Load CSV to powershell variable
$Filename = ".\EXAMPLE--DONE0730339500-9599_Service.csv"
#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
    #Create variables from csv columns
    #$aaname = $user.aaname
    $number = $user.Number
    $upn = $user.UPN
    #
    #
    #
    #Set phone number to resource account with error listing
    Set-CsOnlineVoiceApplicationInstance -identity $upn -TelephoneNumber $number -ErrorAction silentlycontinue

    if($? -ne 'False')
    {
    write-host 'Display Name' $upn -ForegroundColor Red
    write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor DarkRed
    #Closing 1st if loop
    }
    else{
    #Display line to track progress through foreach loop
    write-host 'Assigning number' $number 'to' $upn -ForegroundColor DarkCyan
    #Closing 1st else loop
    }
    #
    #
    #
    #Grant VoiceRouting Policy with error listing
    Grant-CsOnlineVoiceRoutingPolicy -identity $upn -PolicyName $Null
    if($? -ne 'False')
    {
    write-host 'Resource Account' $upn -ForegroundColor Red
    write-host 'Failed due to' $Error[0].Exception.Message -ForegroundColor DarkRed
    #Closing 2nd if loop
    }
    else{
    #Display line to track progress through foreach loop
    write-host 'Assigning Global Voice route Policy to' $upn -ForegroundColor DarkCyan
    #Closing 2nd else loop
    }
    #Closing for each loop
    }

Disconnect-MicrosoftTeams