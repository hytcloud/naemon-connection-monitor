<#
.SYNOPSIS
Detect reconnection by comparing current and previous connection states

.DESCRIPTION
This script checks if a specific IP:Port has reconnected within a given expiration window.

.PARAMETER ip
Target IP address

.PARAMETER port
Target port number

.PARAMETER hour
Expiration in hours

.EXAMPLE
check_reconnect 10.2.8.143 6201 6
check_reconnect -ip 10.2.8.143 -port 6201 -hour 6

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
	$hour
)

# 狀態檔案路徑
$file = [System.IO.Path]::GetTempPath() + "reconnect_${ip}_${port}.txt"

# 確保檔案存在
if (-not (Test-Path $file)) {
	New-Item -Path $file -ItemType File -Force | Out-Null
	Set-Content -Path $file -Value '' -Encoding UTF8
}

# 判斷是否過期
$expired = ((Get-Date) - (Get-Item $file).LastWriteTime) -gt [TimeSpan]::FromHours($hour)

# 取得目前所有 ESTABLISHED 的遠端 endpoint（IP:port）
$currentEndpoints = @(netstat -tn | Select-String "${ip}:${port}" | Select-String ESTABLISHED | ForEach-Object {
	($_ -split '\s+')[-2]  # 取得 remote IP:port
})

# 如果目前沒有任何連線
if (-not $currentEndpoints -or $currentEndpoints.Count -eq 0) {
	Write-Output "CRITICAL - 無連線 ${ip}:${port}"
	exit 2
}

# 如果狀態檔過期，重設為目前連線
if ($expired) {
	Set-Content -Path $file -Value ($currentEndpoints -join "`n") -Encoding UTF8
	Write-Output "OK - 第一次確認 ${ip}:${port}"
	exit 0
}

# 讀取之前的 endpoint 清單
$previousEndpoints = @(Get-Content -Path $file -Encoding UTF8)

# 比對是否完全相同
$matched = ($currentEndpoints | Where-Object { $previousEndpoints -contains $_ }).Count

if ($matched -eq $currentEndpoints.Count) {
	Write-Output "OK - 未重連 ${ip}:${port}"
	exit 0
} else {
	Set-Content -Path $file -Value ($currentEndpoints -join "`n") -Encoding UTF8
	Write-Output "CRITICAL - 已重連 ${ip}:${port}"
	exit 2
}