# The configuration of custom Music on Hold starts with uploading the audio file. You use the PowerShell cmdlet Import-CsOnlineAudioFile
# for this purpose. An example of uploading an MP3 audio file using the PowerShell interface is shown below:
$content = Get-Content "C:\temp\RoyaltyFree-Custom-MoH.mp3" -Encoding byte -ReadCount 0
$AudioFile = Import-CsOnlineAudioFile -FileName "RoyaltyFree-Custom-MoH.mp3" -Content $content
$UserUPN = "stephen.bell@Entag.com.au"
$AudioFile

# To get information about your uploaded audio files, use the Get-CsOnlineAudioFile cmdlet.
Get-CsOnlineAudioFile

# After you have uploaded the audio file, you need to reference the file in a Teams Call Hold Policy
# by using the Id of the file when you create or set a Teams Call Hold Policy. For example:
New-CsTeamsCallHoldPolicy -Identity "CustomMoH1" -Description "Custom MoH using CustomMoH1.mp3" -AudioFileId $AudioFile.Id

# To get a list your Teams Call Hold Policies:
Get-CsTeamsCallHoldPolicy

# After you have created the new Teams Call Hold Policy, you can grant it to your users using Grant-CsTeamsCallHoldPolicy as follows:
Grant-CsTeamsCallHoldPolicy -PolicyName "CustomMoH1" -Identity $UserUPN

# use the Get-CsUserPolicyAssignment cmdlet together with the PolicySource parameter to get details of the Teams Call Hold policy associated with the user.
Get-CsUserPolicyAssignment -Identity $UserUPN -PolicyType TeamsCallHoldPolicy | select -ExpandProperty PolicySource

# To get information about your uploaded audio files, use the Get-CsOnlineAudioFile cmdlet.
Get-CsOnlineAudioFile