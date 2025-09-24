<#
.SYNOPSIS
Check connection status by IP and port

.DESCRIPTION
This is a simple PowerShell script to check if a specific IP:Port has active connections.

.PARAMETER ip
Target IP address

.PARAMETER ports
Target port numbers

.PARAMETER count
count

.PARAMETER mode
switch lt/gt

.EXAMPLE
check_connect 10.88.1.48 8070,9671
check_connect -ip 10.88.1.48 -ports 8070,9671
check_connect 10.88.1.48 8070,9671 2
check_connect -ip 10.88.1.48 -ports 8070,9671 -count 2
check_connect 10.88.1.48 8070,9671 2 lt
check_connect -ip 10.88.1.48 -ports 8070,9671 -count 2 -mode lt

.NOTES
version : 2025/09/17

.LINK
https://github.com/hytcloud/naemon-connection-monitor.git
#>

Param (
	[Parameter(Mandatory = $true, Position = 0)]
	[string]$ip,
	[Parameter(Mandatory = $true, Position = 1)]
	[string[]]$ports,
	[Parameter(Mandatory = $false, Position = 2)]
	[int]$count,
	[Parameter(Mandatory = $false, Position = 3)]
	[string]$mode = 'ne'
)

$result = 0

if ($ports.Count -eq 1 -and $ports[0] -match ",") {
	$ports = $ports[0] -split "," | ForEach-Object { $_.Trim() }
}

foreach ($port in $ports) {
	$result += (netstat -tn | Select-String -Pattern "\s${ip}:${port}\s" | Select-String ESTABLISHED | Measure-Object).count
}

function condition {
	if ($mode -eq 'gt') {
		return ($count -gt $result)
	}
	elseif ($mode -eq 'lt') {
		return ($count -lt $result)
	}
	else {
		return ($count -ne $result)
	}
}

$portsText = $ports -join ","

if ($PSBoundParameters.ContainsKey('count') -And (condition)) {
	Write-Host "CRITICAL - ${ip}:${portsText} 連線數 $result"
	exit 2
}
else {
	Write-Host "OK - ${ip}:${portsText} 連線數 $result"
	exit 0
}