Get-VMNetworkAdapter -VMName "opnsense" |
    Select-Object VMName, Name, MacAddress
