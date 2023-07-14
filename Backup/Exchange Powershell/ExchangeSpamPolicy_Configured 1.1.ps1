#Exchange online connection
Connect-ExchangeOnline



#Create Policy parameters
#Removed ‘zapenabled’ = $true and replaced with PhishZapEnabled and SpamZapEnabled

$policyparams = @{
“name” = “Configured Policy”;
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
'PhishZapEnabled' = $true;
'SpamZapEnabled' = $true
}

#Create policy with parameters
new-hostedcontentfilterpolicy @policyparams

#Create rules for above parameters to apply to
$ruleparams = @{
‘name’ = ‘Configured Policy’;
‘hostedcontentfilterpolicy’ = ‘Configured Policy’;
## this needs to match the above policy name
‘recipientdomainis’ = ‘domain.com’;
## this needs to match the domains you wish to protect in your tenant
‘Enabled’ = $true
}


New-hostedcontentfilterrule @ruleparams