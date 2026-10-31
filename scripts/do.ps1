Get-VMNetworkAdapter -VMName "ipfire" |
    Select-Object Name, SwitchName, MacAddress
