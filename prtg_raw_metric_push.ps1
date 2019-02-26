# This script will push raw metric data to a ServiceNow MIDServer. It is triggered from a PRTG Custom Notification
# 
# Version History
# ----------------------------
# 1.0      initial release
# # # # # # # # # # # # # # # # # # # # # # # # # #
<# Parameters required are the follwing:
metric_type	Name of the metric. e.g. "Disk C: % Free Space/""
resource	Information about the resource for which metric data is being collected. In the example below, C:\ is the resource for which metric data is collected. e.g. "C:\\"
node	IP, FQDN, name of the CI, or host. In the example below, the name of the Linux server where the disks are installed. e.g. "myserver1.domain.com"
value	Value of the metric.  e.g. 50
timestamp	Epoch timestamp of the metric in milliseconds.  e.g. "1551113678000"
source	Data source monitoring the metric type. e.g. "PRTG Metrics"
#>

#Pass placeholders from PRTG custom notification that match the variables below with no value assigned
param( 
		[string]$sensor,    #metric_name
		[string]$name,      #resource 
		[string]$hostname,  #node
		   [int]$lastvalue, #value
		[string]$source     = "PRTG Metrics",    #source
	     [int64]$timestamp  = [int][double]::Parse((Get-Date (get-date).touniversaltime() -UFormat %s)) * 1000   #timestamp
	   
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
$uri = "http://10.96.162.38:8001/api/mid/sa/metrics"

# Specify HTTP method
$method = "post"

# Specify request body
$hash =@{
            metric_type = $sensor;
			resource = $name;
			node = $hostname;
			value  = $lastvalue;
			timestamp = $timestamp;
			source = $source

        }

# Convert hash to JSON
$body = "[$($hash | ConvertTo-Json)]"

# Send HTTP request
$response = Invoke-WebRequest -ContentType 'application/json' -Headers $headers -Method $method -Uri $uri -Body $body

# Print response in Powershell environment
$response.RawConten