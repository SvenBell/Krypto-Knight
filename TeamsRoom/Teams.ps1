#$Credentials = Get-Credential
#Connect-MsolService -Credential $credentials
Connect-MicrosoftTeams

#get-team

#GroupId                              DisplayName        Visibility  Archived  MailNickName       Description       
#-------                              -----------        ----------  --------  ------------       -----------       
#45a59b79-c986-476e-9301-30dcb98649ec Sales and Tech NZ  Private     False     SalesandTechNZ     Sales and Tech NZ 
#d68ffbaf-0a0b-4ef4-bd0e-24104b900c72 Technical Servi... Private     False     TechnicalServic... Technical Servi...
#89ca2504-25b4-4f00-b456-ec4721e3dd6a Marketing          Private     False     Marketing          Marketing         
#cba8d039-05c2-470f-80c5-eef5acb784df Tech Apps          Private     False     TechApps           Tech Apps         
#e0a2e06c-5c93-4afc-80f2-563cbb3cd0fe Change Champions   Private     False     ChangeChampions    This team is fo...
#8d774cb7-8467-467c-bb02-26933ebf59c8 Abacus-HIRF        Public      False     Abacus-HIRF864     Abacus-HIRF       
#f16afd9e-6ed4-410c-93b9-d171c4488a55 Quality and Ris... Private     False     QualityandRiskM... Quality and Ris...
#b1814433-24d1-4d2e-ae8f-f08e37889628 Finance            Private     False     Finance            Finance           
#9a901dc5-93f9-441e-bfb3-13619b545b42 Virus Management   Private     False     VirusManagement    Virus Management  
#8a9d272e-c644-469f-a748-f17560622ee9 Human Resources    Private     False     HumanResources     Human Resources   
#d4e3ed2d-1e7d-44bd-8224-2644f1540e1f IT                 Private     False     ITTeam             IT Team           
#7c4f034e-8f5b-43ae-8a48-db9acbfbd84e New Zealand        Private     False     NewZealand         New Zealand       
#b6aa7c27-6eb4-4b88-9de6-ee96b8b2d989 Rizio              Private     False     Rizio              Rizio             
#50388e42-72d3-4713-8000-ea8b5303dc9b Immunology         Public      False     Immunology         Immunology        
#6eb4d615-a4ae-4b04-9f75-b2a74e9915b8 Customer care      Private     False     Customercare       Customer care Team
#14de1fc1-5d2e-409b-9683-a3c5ffd7a036 IVD Sales Team     Public      False     IVDSalesTeam       IVD Sales Team    
#5200e4c5-b590-4762-84b2-5d9ed71a64b3 Scientific Rese... Public      False     scientificresea... Scientific Rese...
#7c4a98df-70d3-43ce-87c0-01219f030331 Business Leader... Private     False     BusinessLeaders... Business Leader...
#f2898465-748a-45ae-939c-0d413b51988a Commercial Team    Private     False     CommercialTeam196  Commercial Team   
#a377a19f-78ba-4612-b71b-7924596b1b41 iQ                 Public      False     iQ                 iQ                
#85c57266-15a9-4135-a199-46fd3c4d6d32 Operations Team    Private     False     OperationsTeam     Operations Team   
#cb5a77e3-5319-44dc-b685-eb5cdc5d4622 Executive Leade... Private     False     ExecutiveLeader... Executive Leade...
#99ad3712-aeb1-4921-ae6b-e4d65c843861 Technical Services Private     False     TechnicalServices  Technical Services
#3274e1d6-99d8-40cb-bd2a-2246170f76d8 Sales Team         Private     False     SalesTeam          Sales Team  
#

#get-teamchannel -groupid "3274e1d6-99d8-40cb-bd2a-2246170f76d8"

#Id                                               DisplayName                    Description
#--                                               -----------                    -----------
#19:e88774fea58e41e0bc244b64626e2e1c@thread.tacv2 General                                   
#19:43b34c5dbfd54f2ea93b467186a4f308@thread.tacv2 Australian Sales Team                     
#19:afb27540fa174d9b860fd2732574b622@thread.tacv2 IVD Sales Team                            
#19:cbb2a7bc877c4e36b4e5dc9b7293a2bc@thread.tacv2 Scientific Research Sales Team            
#19:05779f28f4d34b029d3818808ddbe2a2@thread.tacv2 Australian Applications Team              
#19:1dd58db7e7b6451f890adbc3b09c89a4@thread.tacv2 Northern Applications Team                
#19:5c154b2c14704e7c87fab129eb2ee773@thread.tacv2 Southern Applications Team



add-Teamchanneluser -groupid "19:43b34c5dbfd54f2ea93b467186a4f308@thread.tacv2" -user    


Get-teamuser -Groupid "3274e1d6-99d8-40cb-bd2a-2246170f76d8" | Export-Csv C:\temp\abacus\salesusers.csv

Connect-MicrosoftTeams

#Filename is the csv with user list heading UPN

$Filename = "C:\Temp\abacus\SalesChannels.csv"
$sfboSession = New-CsOnlineSession
Import-PSSession $sfboSession

    $users = Import-Csv $FileName
    #Connect-MSOLService
    foreach ($user in $users)
    {
        $upn= $user.UPN
        $channel = $user.Channel
        $channeldisplay = $user.ChannelDisplay 
        Add-TeamChannelUser -GroupId $channel -DisplayName $channeldisplay -user $upn
        $ChannelDisplay = Get-TeamChannel -groupid $channel | Displayname
        write-host $upn "Added to" $channeldisplay -foregroundcolor Green
    } 