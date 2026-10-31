# Run PowerShell as Administrator
$interfaceAlias = "Ethernet"

# Disable DHCP
Set-NetIPInterface -InterfaceAlias $interfaceAlias -AddressFamily IPv4 -Dhcp Disabled

# Set the IPv4 address, subnet mask (/24 = 255.255.255.0), and default gateway
New-NetIPAddress -InterfaceAlias $interfaceAlias `
    -IPAddress "192.168.0.100" `
    -PrefixLength 24 `
    -DefaultGateway "192.168.0.1"

# Set DNS servers
Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias `
    -ServerAddresses ("1.1.1.1", "8.8.8.8")

# Verify the network configuration
Get-NetIPConfiguration -InterfaceAlias $interfaceAlias
