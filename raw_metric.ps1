# This script will push raw metric data to a ServiceNow MIDServer. It is triggered from a PRTG Custom Notification
# 
# Version History
# ----------------------------
# 1.0      initial release
# # # # # # # # # # # # # # # # # # # # # # # # # #
param( 
       [string]$sensor       = "",    #metric_name
       [string]$name         = "",    #resource 
       [string]$hostname     = "",    #node
          [int]$lastvalue    = ""     #value
     #[DateTime]$timestamp = ""      #timestamp
)

# Eg. User name="admin", Password="admin" for this code sample.
$user = "snow"
$pass = "Sn0w@1234"

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))

# Specify endpoint uri - REST Protocol
$uri = "http://192.168.22.25:8001/api/mid/sa/metrics"

# Specify HTTP method
$method = "post"

#Get time in Unix Format
$mills_time = [int][double]::Parse((Get-Date (get-date).touniversaltime() -UFormat %s)) * 1000


#Get random value for testing
$value = Get-Random -Minimum 40 -Maximum 50

# Specify request body
$hash =@{
            metric_type = $sensor;
			resource = $name;
			node = $hostname;
			value  = $lastvalue;
			timestamp = $mills_time;
			source = "PRTG Metrics"

        }

# Convert hash to JSON
$body = "[$($hash | ConvertTo-Json)]"

# Send HTTP request
$response = Invoke-WebRequest -ContentType 'application/json' -Headers $headers -Method $method -Uri $uri -Body $body

# Print response in Powershell environment
$response.RawConten

