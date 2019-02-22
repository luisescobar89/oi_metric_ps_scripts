# Eg. User name="admin", Password="admin" for this code sample.
$text = Get-Content credentials.txt
$user = $text[0]
$pass = $text[1]

#$text1 = Get-Content c:/CloudDimensions/EventGeneration/host2.txt
$node = $text1[0]
$hostname = $text1[1]
#test
# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))

# Specify endpoint uri - REST Protocol
$uri = $text[2]

# Specify HTTP method
$method = "post"

# Specify request body
$hash = @{
		source = "SolarWinds";
		node = "$node";
		message_key = "MID10003";
        severity    = "2";
        description = "Low Disk Space on Server " + $hostname;
		type = "MIDSimulator";
		event_class = "hardware";
		additional_info = "Status of server is up"
         }

# Convert hash to JSON
$body = $hash | ConvertTo-Json

# Send HTTP request
$response = Invoke-WebRequest -ContentType 'application/json' -Headers $headers -Method $method -Uri $uri -Body $body

# Print response in Powershell environment
$response.RawConten