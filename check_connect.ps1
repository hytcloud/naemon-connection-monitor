<#
.SYNOPSIS
Check connection status by IP and port

.DESCRIPTION
This is a simple PowerShell script to check if a specific IP:Port has active connections.

.PARAMETER ip
Target IP address

.PARAMETER port
Target port number

.PARAMETER count
count

.EXAMPLE
check_connect 10.2.8.143 6201
check_connect -ip 10.2.8.143 -port 6201

.NOTES
version : 2025/08/26

.LINK
https://github.com/hytcloud/naemon-connection-monitor.git
#>

Param (
	[Parameter(Mandatory = $true, Position = 0)]
	$ip,
	[Parameter(Mandatory = $true, Position = 1)]
	$port,
	[Parameter(Mandatory = $true, Position = 2)]
	$count
)

$result = (netstat -tn | Select-String -Pattern "${ip}:${port}" | Select-String ESTABLISHED | Measure-Object)
$connect = $result.count

if ($connect -eq $count) {
	Write-Host "OK - ${ip}:${port} 連線數 $connect"
	exit 0
}
else {
	Write-Host "CRITICAL - ${ip}:${port} 連線數 $connect"
	exit 2
}
