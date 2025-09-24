# naemon-connection-monitor
PowerShell scripts for monitoring inbound connections to a specific IP:Port, designed to run directly on the target host. Includes tools for checking current connection count and detecting reconnection events over time. Compatible with Windows PowerShell and PowerShell Core on Linux.

## Installation
Clone the repository and navigate to the script directory:
```bash
git clone https://github.com/hytcloud/naemon-connection-monitor.git
cd naemon-connection-monitor
```

## Table of Contents
- [check_connect.ps1](#check_connectps1)
- [check_reconnect.ps1](#check_reconnectps1)

## check_connect.ps1
**Description**
Checks how many active inbound connections exist to the specified IP and port(s). Supports multiple ports, threshold comparison using -count with a comparison -mode, and outputs standard Naemon plugin exit codes.

**Usage**
```powershell
.\check_connect.ps1 -ip <target_ip> -ports <port1,port2,...> [-count <expected_connection_count>] [-mode <gt|lt|ne>]
```

**Options**
| Option   | Description                                                                 |
|----------|-----------------------------------------------------------------------------|
| `-ip`    | Target IP address                                                           |
| `-ports` | Target port number(s), comma-separated                                      |
| `-count` | Expected number of inbound connections (used for threshold comparison)      |
| `-mode`  | Comparison mode:<br>• `gt` → OK if actual count is **greater than or equal to** expected<br>• `lt` → OK if actual count is **less than or equal to** expected<br>• `ne` → OK if actual count is **exactly equal** to expected (default) |

**Notes**
- If -count is not specified, the script performs a simple connection check and returns OK
- If -mode is omitted, comparison defaults to ne (not equal)
- Version: 2025/09/16
- [GitHub Repo](https://github.com/hytcloud/naemon-connection-monitor.git)

## check_reconnect.ps1

**Description**
Detects whether a specific IP:Port has reconnected by comparing current connection state with previously recorded data.

**Usage**
```powershell
.\check_reconnect.ps1 -ip <target_ip> -port <target_port> -hour <expiration_window>
```

**Options**
| Option   | Description                                                  |
|----------|--------------------------------------------------------------|
| `-ip`    | Target IP address                                            |
| `-port`  | Target port number                                           |
| `-hour`  | Expiration window in hours (older records are considered expired) |

**Notes**
- Stores connection state in a temporary file for comparison.
- Reconnection is detected if a previously missing connection reappears within the expiration window.
- Version: 2025/08/26
- [GitHub Repo](https://github.com/hytcloud/naemon-connection-monitor.git)