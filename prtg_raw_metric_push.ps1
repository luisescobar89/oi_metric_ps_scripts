# This script will push raw metric data to a ServiceNow MIDServer. It is triggered from a PRTG Custom Notification
# 
# Version History
# ----------------------------
# 1.0      initial release
# 1.1      added logic for parsing metric value from message variable
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
		[string]$shortname, #resource 
		[string]$hostname,  #node
		[string]$message,   #value
		[string]$uri,       #midserver endpoint url
		[string]$source     = "PRTG Metrics",    #source
		 [int64]$timestamp  = [int][double]::Parse((Get-Date (get-date).touniversaltime() -UFormat %s)) * 1000   #timestamp			   
)

if (!$uri -or !$sensor -or !$shortname -or !$hostname -or !$message) {

	#Missing parameters, end script execution
	exit 1
}

function Get-MetricValues {
	param ($description)
	[array]$myarr = $description.split(" ")

	foreach($val in $myarr){
		if ($val -match '^[+-]?([0-9]*[.])?[0-9]+'){
			return [double]$val
		}
	}
}

#get metric value from message string and convert to float
$value = Get-MetricValues $message

if ($value.count -eq 0){
	#No metric value obtained from message, end script execution
	exit 2
}

# Eg. User name="admin", Password="admin" for this code sample.
$user = "snow"
$pass = "Sn0w@1234"

# Build auth header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

# Set proper headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))

# Specify HTTP method
$method = "post"

# Specify request body
$hash =@{
            metric_type = $sensor;
			resource = $shortname;
			node = $hostname;
			value  = $value;
			timestamp = $timestamp;
			source = $source

        }

# Convert hash to JSON
$body = "[$($hash | ConvertTo-Json)]"

#Write-Host $body #uncomment to view JSON object

# Send HTTP request
try{
$response = Invoke-WebRequest -ContentType 'application/json' -Headers $headers -Method $method -Uri $uri -Body $body
}
catch{
	Write-Host -ForegroundColor:Red "Error Invoking WebRequest to $($uri)"
	Write-Host -ForegroundColor:Red $_.Exception.ToString()
}

# Print response in Powershell environment
$response.RawConten