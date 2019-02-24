# Eg. User name="admin", Password="admin" for this code sample.
$text = Get-Content credentials.txt
$user = $text[0]
$pass = $text[1]

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))

# Specify endpoint uri - REST Protocol
$uri = $text[2]

# Specify HTTP method
$method = "post"

#Get time in Unix Format
$unix_time = [int][double]::Parse((Get-Date -UFormat %s))

#Get random value for testing
$value = Get-Random -Maximum 100

# Specify request body
$hash =@{
            metric_type = 'Disk E: % Free Space'
			resource = "E:\";
			node = "nywvdpr02";
			value  = $value;
			timestamp = $unix_time;
			source = "PRTG Metrics"
        }
				 
# Convert hash to JSON
$body = "[$($hash | ConvertTo-Json)]"

Write-Host $body

# Send HTTP request
$response = Invoke-WebRequest -ContentType 'application/json' -Headers $headers -Method $method -Uri $uri -Body $body

# Print response in Powershell environment
$response.RawConten
