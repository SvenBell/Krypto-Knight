$Autoattendant = "AA-Main"

$AAResource = @($Autoattendant)

$CQ1 = "CQ-Reception"

$BusinessHours = Monday - Friday 8-5
 $AAAnnounce = "Welcome to Concept Safety. Please hold the line while we connect you with one of the team."  $AAAfterhoursAnnounce = "Thank you for calling Concept Safety. You have reached us outside of our normal office hours. Please hold to leave a voicemail with your, name and contact number, and one of our friendly staff will return your call."  $ReceptionQAA = "AA-ReceptionQ"  $Voicemail = "ReceptionVmail"  $RoutingMethod =   $TimeZone =   #Create Call Queue1  #Create Office 365 group set for Voicemail  #Create Resource account , set language, set operator to CQ1  #Create AAMain  #Attach Resource account to AAMain  #Attach Greeting to AAMain  #Attach Business hours to AAMain  #Redirect AAMain to CQ1  #AfterHours Redirect to Voicemail office 365  #Dial scope include All online users exclude none  CSAutoAttendant commands  PS C:\WINDOWS\system32> Get-Command “*-CsAutoAttendant*”

CommandType     Name                                               Version    Source                                                                 
-----------     ----                                               -------    ------                                                                 
Function        Export-CsAutoAttendantHolidays                     1.0        tmp_0fxcwj3g.i1v                                                       
Function        Get-CsAutoAttendant                                1.0        tmp_0fxcwj3g.i1v                                                       
Function        Get-CsAutoAttendantHolidays                        1.0        tmp_0fxcwj3g.i1v                                                       
Function        Get-CsAutoAttendantStatus                          1.0        tmp_0fxcwj3g.i1v                                                       
Function        Get-CsAutoAttendantSupportedLanguage               1.0        tmp_0fxcwj3g.i1v                                                       
Function        Get-CsAutoAttendantSupportedTimeZone               1.0        tmp_0fxcwj3g.i1v                                                       
Function        Get-CsAutoAttendantTenantInformation               1.0        tmp_0fxcwj3g.i1v                                                       
Function        Import-CsAutoAttendantHolidays                     1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendant                                1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendantCallableEntity                  1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendantCallFlow                        1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendantCallHandlingAssociation         1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendantDialScope                       1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendantMenu                            1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendantMenuOption                      1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsAutoAttendantPrompt                          1.0        tmp_0fxcwj3g.i1v                                                       
Function        Remove-CsAutoAttendant                             1.0        tmp_0fxcwj3g.i1v                                                       
Function        Set-CsAutoAttendant                                1.0        tmp_0fxcwj3g.i1v                                                       
Function        Update-CsAutoAttendant                             1.0        tmp_0fxcwj3g.i1v 

#Call queue commands

PS C:\WINDOWS\system32> Get-Command “*callqueue*”

CommandType     Name                                               Version    Source                                                                 
-----------     ----                                               -------    ------                                                                 
Function        Get-CsCallQueue                                    1.0        tmp_0fxcwj3g.i1v                                                       
Function        New-CsCallQueue                                    1.0        tmp_0fxcwj3g.i1v                                                       
Function        Remove-CsCallQueue                                 1.0        tmp_0fxcwj3g.i1v                                                       
Function        Set-CsCallQueue                                    1.0        tmp_0fxcwj3g.i1v



New-CsOnlineApplicationInstance


New-CsOnlineApplicationInstanceAssociation


