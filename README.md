# naemon-connection-monitor

PowerShell scripts for monitoring inbound connections to a specific IP:Port, designed to run directly on the target host. Includes tools for checking current connection count and detecting reconnection events over time. Compatible with Windows PowerShell and PowerShell Core on Linux.

check_connect.ps1
Description
Checks how many active inbound connections exist to the specified IP and port.
Usage
.\check_connect.ps1 -ip <target_ip> -port <target_port> -count <expected_connection_count>

Options
- -ip    Target IP address
- -port   Target port number
- -count  Expected number of inbound connections (used for threshold comparison)
Notes
- Exit code reflects whether the actual connection count matches the expected value.
- Version: 2025/08/26
- GitHub Repo

check_reconnect.ps1
Description
Detects whether a specific IP:Port has reconnected by comparing current connection state with previously recorded data.
Usage
.\check_reconnect.ps1 -ip <target_ip> -port <target_port> -hour <expiration_window>

Options
- -ip    Target IP address
- -port   Target port number
- -hour  Expiration window in hours (older records are considered expired)
Notes
- Stores connection state in a temporary file for comparison.
- Reconnection is detected if a previously missing connection reappears within the expiration window.
- Version: 2025/08/26
- GitHub Repo