Function IPToInt($ip) {
    $bytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
    [Array]::Reverse($bytes)
    [UInt32]([System.BitConverter]::ToUInt32($bytes,0))
}

Function IntToIP($int) {
    $bytes = [System.BitConverter]::GetBytes($int)
    [Array]::Reverse($bytes)
    ([System.Net.IPAddress]::new($bytes)).ToString()
}

$networks = @(
    "10.1.0.0/24",
    "10.1.8.0/23",
    "10.1.2.0/24",
    "10.1.4.0/22"
)

ForEach ($network in $networks) {
    $networkParts = $network.Split('/')
    $networkAddress = $networkParts[0]
    $prefixLength = [int]$networkParts[1]

    # Calculate subnet mask
    $mask = [uint32](0xFFFFFFFF << (32 - $prefixLength))

    # Convert network address to integer
    $networkInt = IPToInt($networkAddress)

    # Calculate network and broadcast addresses
    $networkInt = $networkInt -band $mask
    $broadcastInt = $networkInt -bor (~$mask)

    # Loop through IPs in the range
    For ($ipInt = $networkInt; $ipInt -le $broadcastInt; $ipInt++) {
        $ipAddress = IntToIP($ipInt)

        # Ping the IP address 5 times silently
        $pingResult = Test-Connection -Count 5 -Quiet -ComputerName $ipAddress -ErrorAction SilentlyContinue

        If ($pingResult) {
            Write-Host $ipAddress -ForegroundColor Green
        } Else {
            Write-Host $ipAddress -ForegroundColor Red
        }
    }
}
