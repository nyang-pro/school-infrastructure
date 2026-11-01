# Enable VLAN trunking on the OPNsense LAN adapter
Set-VMNetworkAdapterVlan -VMName "opnsense" `
    -VMNetworkAdapterName "KIFORMATOU" `
    -Trunk -AllowedVlanIdList "20,30" -NativeVlanId 0

# Verify VLAN settings on both VMs
Get-VMNetworkAdapterVlan -VMName "opnsense", "pve"
