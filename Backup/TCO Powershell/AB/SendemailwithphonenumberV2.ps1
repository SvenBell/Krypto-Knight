
Connect-MicrosoftTeams


#Filename is the csv with user list heading UPN
#CSV file requires first line to have Heading Name, UPN and Number are needed, 
#if the number is blank it should remove the number from the user.
$Filename = "C:\GitHub\PowerShell\TCO Powershell\AB\ABENTAG-User-numbers.csv"

#Import data from CSV file into $users variable as a table
    $users = Import-Csv $FileName
    #for each user line in users table do the following
    foreach ($user in $users)
    {
        #Set $upn variable to equal Users UPN
        $upn= $user.UPN
        #Set $number variable to equal Users phone number
        $number= $user.Number
        #Set $name variable to equal Users name
        #$name= $user.Name
        #Log current users license status to pre change log file
        $displayname = Get-CsOnlineuser -identity $upn | Select DisplayName
        $fdisplayname = $displayname.DisplayName
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv "C:\tools\temp\omnii-Phone.csv" -Append -NoTypeInformation
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        #Dislay to screen
        write-host $upn "assigning" $number -foregroundcolor Green 
        #Update the users Teams phone number
        ##Set-CsOnlineVoiceUser -id $upn -TelephoneNumber $number
        # WARNING: It can take 1-2 minutes for details to change in back end
        #Log current users license status to post change log file
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail | export-csv "C:\tools\temp\omnii-Phone.csv" -Append -NoTypeInformation
        #Get-CsOnlineUser -identity $upn | Select DisplayName,UserPrincipalName,LineURI,EnterpriseVoiceEnabled,Hostedvoicemail
        #Write-Host "-------"
        $From = "andrew.baird@entag.com.au"
        $To = "andrew.baird@entag.com.au"
        $Cc = "andrew.baird@entag.com.au"
        $Subject = "Ring Ring Teams Phone Number"
        $Body = '
        <html xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" xmlns="http://www.w3.org/TR/REC-html40"><head><meta http-equiv=Content-Type content="text/html; charset=utf-8"><meta name=Generator content="Microsoft Word 15 (filtered medium)"><!--[if !mso]><style>v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style><![endif]--><style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:"Segoe UI";
	panose-1:2 11 5 2 4 2 4 2 2 3;}
@font-face
	{font-family:"Segoe UI Semibold";
	panose-1:2 11 7 2 4 2 4 2 2 3;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:blue;
	text-decoration:underline;}
span.EmailStyle20
	{mso-style-type:personal-reply;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 72.0pt 72.0pt 72.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext="edit" spidmax="1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext="edit">
<o:idmap v:ext="edit" data="1" />
</o:shapelayout></xml><![endif]--></head><body lang=EN-AU link=blue vlink=purple style=''word-wrap:break-word''><o:p></o:p></span></p></div></div><p class=MsoNormal><o:p>&nbsp;</o:p></p><p><span style=''font-size:9.0pt;font-family:"Segoe UI",sans-serif''><o:p></o:p></span></p><div><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 style=''object-fit: contain''><tr><td width=1000 style=''width:750.0pt;padding:0cm 0cm 0cm 0cm;border-radius:2px;box-shadow:0 0 10px rgba(0, 0 ,0 ,0.08)''><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0><tr><td style=''border:solid #E6E6E6 1.0pt;padding:0cm 0cm 0cm 0cm;object-fit: contain''><div align=center><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 style=''max-width:450.0pt;background:white''><tr><td colspan=2 style=''padding:24.0pt 24.0pt 0cm 24.0pt''><p class=MsoNormal style=''line-height:18.75pt''><b><span style=''font-size:10.5pt;font-family:"Segoe UI",sans-serif;color:#6264A7''>Microsoft Teams <o:p></o:p></span></b></p></td></tr><tr><td colspan=2 style=''padding:11.25pt 24.0pt 0cm 24.0pt''><p class=MsoNormal><b><span style=''font-size:13.5pt;font-family:"Segoe UI",sans-serif;color:#252424''>Hi $_displayname . Here''s your Teams phone number.</span></b><span style=''color:black''> </span><o:p></o:p></p></td></tr><tr><td colspan=2 style=''padding:6.0pt 24.0pt 14.65pt 24.0pt''><p class=MsoNormal><span style=''font-size:10.5pt;font-family:"Segoe UI",sans-serif;color:black''>It might take up to 48 hours before you can make and receive phone calls.</span><span style=''color:black''> </span><o:p></o:p></p></td></tr><tr><td colspan=2 style=''padding:0cm 24.0pt 0cm 24.0pt''><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%" style=''width:100.0%;background:#FAF9F8;border:solid #EDEBE9 1.0pt;box-sizing: border-box;border-radius: 3px;box-shadow: 0 -2px 4px 0 rgba(0,0,0,0.08)''><tr><td width=32 style=''width:24.0pt;border:none;padding:19.9pt 0cm 19.9pt 19.9pt''><p class=MsoNormal><span style=''color:black''><img width=32 height=32 style=''width:.3333in;height:.3333in'' id="_x0000_i1033" src="https://statics.teams.microsoft.com/evergreen-assets/emails/icons-call-audio.png" alt=Phone></span><o:p></o:p></p></td><td style=''border:none;padding:0cm 0cm 0cm 0cm''><div><p class=MsoNormal><b><span style=''font-size:13.5pt;font-family:"Segoe UI",sans-serif;color:#252424''>$_number</span></b><span style=''color:black''> </span><o:p></o:p></p></div></td></tr></table></td></tr><tr><td colspan=2 style=''padding:14.65pt 24.0pt 33.75pt 24.0pt''><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0><tr><td style=''padding:0cm 0cm 0cm 0cm''><p class=MsoNormal><span style=''font-family:"Segoe UI Semibold",sans-serif''><img width=172 height=44 style=''width:1.7916in;height:.4583in'' id="_x0000_i1032" src="cid:image004.png@01D740BC.84A7FCB0" alt="Open Teams&#13;&#13;&#10;&#13;&#10;"></span><span style=''font-family:"Segoe UI Semibold",sans-serif''><o:p></o:p></span></p></td></tr></table></td></tr><tr><td style=''border:none;border-top:solid #F3F2F1 1.0pt;padding:24.0pt 15.0pt 33.0pt 23.25pt''><p style=''margin:0cm;line-height:15.0pt''><b><span style=''font-size:10.5pt;font-family:"Segoe UI",sans-serif;color:#252424''>What''s Microsoft Teams?</span></b><span style=''font-size:10.5pt;font-family:"Segoe UI",sans-serif;color:#252424''><o:p></o:p></span></p><p style=''margin:0cm;line-height:15.0pt;color:rgba(37,36,36,0.75)''><span style=''font-size:10.5pt;font-family:"Segoe UI",sans-serif;color:black''>The single place where you chat with colleagues, collaborate on files in real time, and make decisions as a team.</span><span style=''font-size:10.5pt;font-family:"Segoe UI",sans-serif''><o:p></o:p></span></p></td><td style=''border:none;border-top:solid #F3F2F1 1.0pt;padding:24.0pt 23.25pt 35.25pt 0cm''><p class=MsoNormal><span style=''color:black''><img width=32 height=32 style=''width:.3333in;height:.3333in'' id="_x0000_i1031" src="https://statics.teams.microsoft.com/icons/microsoft_teams_icon.png" alt="Microsoft Teams"></span><o:p></o:p></p></td></tr><tr><td colspan=2 style=''border:none;border-top:solid #E8E8E8 1.0pt;background:#F8F8F8;padding:7.5pt 24.0pt 24.0pt 24.0pt;border-radius: 0px 0px 1px 1px''><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style=''width:100.0%''><tr><td style=''padding:0cm 0cm 0cm 0cm;valign:top''><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0><tr style=''height:30.0pt''><td style=''padding:.75pt .75pt .75pt .75pt;height:30.0pt''><p class=MsoNormal><span style=''font-size:10.5pt;font-family:"Segoe UI",sans-serif;color:#6E6D6D''>Install Microsoft Teams now<o:p></o:p></span></p></td></tr><tr><td style=''padding:.75pt .75pt .75pt 0cm''><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0><tr style=''height:21.0pt''><td width=46 style=''width:34.5pt;padding:0cm 0cm 0cm 0cm;height:21.0pt''><div><p class=MsoNormal><span style=''font-family:"Segoe UI",sans-serif''><img width=98 height=31 style=''width:1.0166in;height:.325in'' id="_x0000_i1030" src="cid:image005.png@01D740BC.84A7FCB0" alt="   &#13;&#10; &#13;&#10;   &#13;&#10;  iOS&#13;&#10;   &#13;&#13;&#10;&#13;&#10;"></span><span style=''font-family:"Segoe UI",sans-serif''><o:p></o:p></span></p></div></td><td width=10 style=''width:7.5pt;padding:0cm 0cm 0cm 0cm;height:21.0pt;width:px''></td><td width=46 style=''width:34.5pt;padding:0cm 0cm 0cm 0cm;height:21.0pt''><div><p class=MsoNormal><span style=''font-family:"Segoe UI",sans-serif''><img width=98 height=31 style=''width:1.0166in;height:.325in'' id="_x0000_i1029" src="cid:image006.png@01D740BC.84A7FCB0" alt="  &#13;&#10; &#13;&#10;   &#13;&#10;Android&#13;&#10;  &#13;&#13;&#10;&#13;&#10;"></span><span style=''font-family:"Segoe UI",sans-serif''><o:p></o:p></span></p></div></td></tr></table></td></tr></table></td></tr><tr><td style=''padding:21.0pt 0cm 0cm 0cm''><p class=MsoNormal style=''line-height:12.0pt''><span style=''font-size:7.5pt;font-family:"Segoe UI",sans-serif;color:#6E6D6D''>This email was sent from an unmonitored mailbox. Update your email preferences in Teams. Profile picture &gt; Settings &gt; Notifications.<o:p></o:p></span></p></td></tr><tr><td style=''padding:12.0pt 0cm 0cm 0cm''><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style=''width:100.0%''><tr><td style=''padding:0cm 0cm 0cm 0cm''><p class=MsoNormal><span style=''font-size:7.5pt;font-family:"Segoe UI",sans-serif;color:#6E6D6D''>© 2019 Microsoft Corporation, One Microsoft Way, Redmond WA 98052-7329<br>Read our <a href="http://go.microsoft.com/fwlink/p/?LinkID=512132"><span style=''color:#6E6D6D''>privacy policy</span></a> <o:p></o:p></span></p></td></tr></table></td></tr><tr><td style=''padding:15.0pt 0cm 0cm 0cm''><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0><tr><td style=''padding:0cm 0cm 0cm 0cm''><p class=MsoNormal><img border=0 width=99 style=''width:1.0333in'' id="_x0000_i1028" src="https://asgcdn.blob.core.windows.net/office-email-templates/logo_microsoft.png" alt=Microsoft><o:p></o:p></p></td></tr></table></td></tr></table></td></tr></table></div></td></tr><tr><td style=''padding:0cm 0cm 0cm 0cm''><p class=MsoNormal><img border=0 id="_x0000_i1027" src="https://urlshortener.teams.microsoft.com/8D8F4E31C72788E-7-0"><o:p></o:p></p></td></tr></table></div></td></tr></table></div><p class=MsoNormal><o:p>&nbsp;</o:p></p></div></div></body></html>"
'
        $Body += $fdisplayname
        $Body += $number
        #$SMTPServer = "smtp.mailtrap.io"
        $cred = get-credential
        $SMTPPort = "587"
        Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer "smtp.office365.com" -usessl -Credential $cred -Port $SMTPPort
    } 