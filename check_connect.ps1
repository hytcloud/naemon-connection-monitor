<#
.SYNOPSIS
Check connection status by IP and port or process command

.DESCRIPTION
This is a simple PowerShell script to check if a specific IP:Port or process command has active connections.
(process command only for windows)

.PARAMETER ip
Target IP address or process command

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
check_connect abc123 1433
check_connect -command abc123 -ports 1433
check_connect abc123 1433 2
check_connect -command abc123 -ports 1433 -count 2
check_connect abc123 1433 2 lt
check_connect -command abc123 -ports 1433 -count 2 -mode lt

.NOTES
version : 2026/09/09

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
	[string]$mode = 'eq'
)

$result = 0

if ($ports.Count -eq 1 -and $ports[0] -match ',') {
	$ports = $ports[0] -split ',' | ForEach-Object { $_.Trim() }
}

if ($ip -match '^\d{1,3}(\.\d{1,3}){3}$') {
	foreach ($port in $ports) {
		$result += @(netstat -tn | Select-String -Pattern "\s+${ip}:${port}\s+" | Select-String -Pattern 'ESTABLISHED').Count
	}
}
else {
	$upid = (Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*$ip*" } | Select-Object -First 1).ProcessId

	if (-not $upid) {
		$portsText = $ports -join ','
		$perfData = 'connections=0;;;;'

		Write-Host "CRITICAL - ${ip} not found | $perfData"
		exit 2
	}

	foreach ($port in $ports) {
		$result += @(netstat -no -p TCP | Select-String -Pattern ":${port}\s+ESTABLISHED\s+${upid}`$").Count
	}
}

$portsText = $ports -join ','

$triggered = switch ($mode) {
	'gt' {
		$count -gt $result
	}
	'lt' {
		$count -lt $result
	}
	default {
		$count -ne $result
	}
}

$perfData = "connections=$result;;;;"

if ($PSBoundParameters.ContainsKey('count') -and $triggered) {
	Write-Host "CRITICAL - ${ip}:${portsText} 連線數 $result | $perfData"
	exit 2
}
else {
	Write-Host "OK - ${ip}:${portsText} 連線數 $result | $perfData"
	exit 0
}