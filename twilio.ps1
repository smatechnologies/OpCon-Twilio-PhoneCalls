<#

InitiateTwilioCall.ps1

Version History:

  2018/05/10: Initial creation with basic functionality and 
  logging.                                                   
                                                             
#>

param(
[string]$TwilioAccountSID,
[string]$TwilioAuthToken,
[string]$TwilioNumber,
[string]$PhoneNumber,
[string]$Message
)

try
{
    Add-Type -AssemblyName System.Web

    Write-Host "Target Phone Number: $PhoneNumber`n"
    Write-Host "Voice Message: $Message`n"

    $Message = [System.Web.HttpUtility]::UrlEncode($Message)

    $TwiMLUrl = "http://twimlets.com/message?Message%5b0%5d=$Message"

    Write-Host "TwiML URL: $TwimlUrl`n"

    # Twilio API endpoint and POST params
    $url = "https://api.twilio.com/2010-04-01/Accounts/$TwilioAccountSID/Calls.json"
    $params = @{ To = "+$PhoneNumber"; From = "+$TwilioNumber"; Url = $TwiMLUrl }

    # Create a credential object for HTTP basic auth
    $p = $TwilioAuthToken | ConvertTo-SecureString -asPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($TwilioAccountSID, $p)

    # Make API request, selecting JSON properties from response
    $result = Invoke-WebRequest $url -Method Post -Credential $credential -Body $params -UseBasicParsing | ConvertFrom-Json

    Write-Host "Response: `n"
    $result | Format-List

}
catch
{
    $_.Exception | Format-List
    Exit 1
}