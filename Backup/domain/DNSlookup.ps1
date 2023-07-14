$domain = "entag.com.au"

#MX lookup systems
$Uri = 'https://dns.google.com/resolve?name={0}&type=mx' -f $domain
$MX = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

write-host $MX

#CNAME Microsoft record lookup
$autodiscover = "autodiscover."
$AutoCNAME = $autodiscover+$domain
$Uri = 'https://dns.google.com/resolve?name={0}&type=cname' -f $AutoCNAME
$Auto = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

write-host $Auto


$sip = "sip."
$sipCNAME = $sip+$domain
$Uri = 'https://dns.google.com/resolve?name={0}&type=cname' -f $sipCNAME
$CNAME = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

write-host $CNAME

$lync = "lyncdiscover."
$lyncCNAME = $lync+$domain
$Uri = 'https://dns.google.com/resolve?name={0}&type=cname' -f $lyncCNAME
$LD = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

Write-Host $LD


$entReg = "enterpriseregistration."
$entRegCname = $entReg+$domain
$Uri = 'https://dns.google.com/resolve?name={0}&type=cname' -f $entRegCname
$ER = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

Write-host $ER

$entEnroll = "enterpriseenrollment."
$entEnrollCname = $entEnroll+$domain
$Uri = 'https://dns.google.com/resolve?name={0}&type=cname' -f $entEnrollCname
$Enroll = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

Write-host $enroll

#SRV records
$_SIP = "_sip._tls."
$sipSRV = $_SIP+$domain
$Uri = 'https://dns.google.com/resolve?name={0}&type=SRV' -f $sipSRV
$SIPTLS = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

Write-host $SIPTLS

$_SIPFED = "_sipfederationtls._tcp."
$sipFedSRV = $_SIPFED+$domain
$Uri = 'https://dns.google.com/resolve?name={0}&type=SRV' -f $sipFedSRV
$SFS = (Invoke-RestMethod -Uri $URI).Answer.data -replace '^\d+\s'

write-host $SFS

#Verification agianst what should exist (excludes MX)

If ($AutoCNAME = $Auto){
    $automsg = $Auto + "- the Record is Correct"
} else { 
    $automsg = $Auto + "- RECORD INCORRECT"
}

If ($sipCNAME = $CNAME){
    $cnamemsg = $CNAME + "- the Record is Correct"
} else { 
    $cnamemsg = $sipCNAME + "- RECORD INCORRECT"
}

If ($lyncCNAME = $LD){
    $lyncmsg = $LD + "- the Record is Correct"
} else { 
    $lyncmsg = $lyncCNAME + "- RECORD INCORRECT"
}

If ($entRegCname = $ER){
    $ermsg = $ER + "- the Record is Correct"
} else { 
    $ermsg = $entRegCname + "- RECORD INCORRECT"
}

If ($entEnrollCname = $Enroll){
    $entmsg = $Enroll + "- the Record is Correct"
} else { 
    $entmsg = $entEnrollCname + "- RECORD INCORRECT"
}

If ($sipSRV = $SIPTLS){
    $sipmsg = $SIPTLS + "- the Record is Correct"
} else { 
    $sipmsg = $sipSRV + "- RECORD INCORRECT"
}

If ($sipFedSRV = $SFS){
    $srvmsg = $sipFedSRV + "- the Record is Correct"
} else { 
    $srvmsg = $SFS + "- RECORD INCORRECT"
}


Write-host $automsg $cnamemsg $lyncmsg $ermsg $entmsg $sipmsg $srvmsg
