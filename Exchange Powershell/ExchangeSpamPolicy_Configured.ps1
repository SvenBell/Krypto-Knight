#Script to ENTAG recommended initial Configured create SPAM Filter Policy

#Exchange online connection
Connect-ExchangeOnline

#Create Policy parameters

$policyparams = @{
“name” = “Configured Spam filter Policy”;
#Changed name above for better description
‘Bulkspamaction’ =  ‘movetojmf’;
‘bulkthreshold’ =  ‘7’;
‘highconfidencespamaction’ =  ‘movetojmf’;
‘inlinesafetytipsenabled’ = $true;
‘markasspambulkmail’ = ‘on’;
‘increasescorewithimagelinks’ = ‘off’
‘increasescorewithnumericips’ = ‘on’
‘increasescorewithredirecttootherport’ = ‘on’
‘increasescorewithbizorinfourls’ = ‘on’;
‘markasspamemptymessages’ =’on’;
‘markasspamjavascriptinhtml’ = ‘on’;
‘markasspamframesinhtml’ = ‘on’;
‘markasspamobjecttagsinhtml’ = ‘on’;
‘markasspamembedtagsinhtml’ =’on’;
‘markasspamformtagsinhtml’ = ‘on’;
‘markasspamwebbugsinhtml’ = ‘on’;
‘markasspamsensitivewordlist’ = ‘on’;
‘markasspamspfrecordhardfail’ = ‘on’;
‘markasspamfromaddressauthfail’ = ‘on’;
‘markasspamndrbackscatter’ = ‘on’;
‘phishspamaction’ = ‘movetojmf’;
‘spamaction’ = ‘movetojmf’;
#Fixed line below as it was missing spam in front of zapenabled
‘spamzapenabled’ = $true
}

#Create policy with parameters
new-hostedcontentfilterpolicy @policyparams

#Create rules for above parameters to apply to
$ruleparams = @{
‘name’ = ‘Configured Spam filter Policy’;
‘hostedcontentfilterpolicy’ = ‘Configured Spam filter Policy’;
## this needs to match the above policy name
‘recipientdomainis’ = ‘domain.com’;
## this needs to match the domains you wish to protect in your tenant i.e. sjatkinsplumbing.com.au
‘Enabled’ = $false
##Line above can be $true or $false
}

#Create the new rule
New-hostedcontentfilterrule @ruleparams