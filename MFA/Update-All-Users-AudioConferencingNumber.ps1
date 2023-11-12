# To See current state
get-CsOnlineDialInConferencingUser | Select DisplayName, SipAddress, DefaultTollNumber | Sort-Object -property SipAddress | FT

#Set all Audio Conference user's 

get-CsOnlineDialInConferencingUser | Where-Object {$_.servicenumber -eq 61272084711} | %{Set-CsOnlineDialInConferencingUser -identity $_.sipaddress.substring(4) -ServiceNumber 61721399723}
#Set-CsOnlineDialInConferencingUser -ServiceNumber 61721399723

# To see result
get-CsOnlineDialInConferencingUser | Select DisplayName, SipAddress, DefaultTollNumber | Sort-Object -property SipAddress | FT