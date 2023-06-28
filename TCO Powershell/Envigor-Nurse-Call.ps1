##AUTHOR NOTES$$ - Written by Bryton I. Wishart (anothecloudblog.com) the purpose of this script is to receive
## paramaters from a Microsoft flow, Clean the australian mobile number provided and convert it to international
## standards and remove white spaces. Append Tel: to the start and update a call queue to redirect calls to that number.

#Add in information from Flow
 Param
     (
         [Parameter (Mandatory= $true)]
         [String] $CallQueue = "",
         [Parameter (Mandatory = $true)]
         [String] $usernumber = ""
     )

#Static Variables
$credname = "PowerAutomate"

#Clean Number and remove white spaces and drop leading Zero, if number is either 04 or +61 fix number.
If($usernumber -contains "+"){
    $NumberCleaned = $usernumber -replace ' ', ''
    #write-host "Removed White spaces on +61" $NumberCleaned
} else {
    $clean = $usernumber -replace '^0+', '+61'
    #write-host "Added +61" $clean
    $NumberCleaned = $clean -replace ' ', ''
    #write-host "white spaces removed" $NumberCleaned
}

#Variable constructed for correct teams format which is tel:+61 univerisal number
$tel = "tel:"
$number = $tel + $NumberCleaned

# Authenication to Teams
$Cred = Get-AutomationPSCredential -Name $credname
Connect-MicrosoftTeams -Credential $Cred

#Get-CSCallQueue -Name "CQ-NurseCall"

#Set Queue Number Redirection
Set-CsCallQueue -identity $CallQueue -TimeOutActionTarget $number

#write-host $number has been updated in the call Queue
