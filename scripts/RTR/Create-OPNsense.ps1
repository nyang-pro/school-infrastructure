<#
.SYNOPSIS
    Creates a Hyper-V virtual machine.

.DESCRIPTION
    Creates and configures a Hyper-V virtual machine for automation.

.NOTES
    Author  : Nathan Yang
    Version : 1.0.0
    Status  : OK (WIP)
#>

# Configuration
$OPNsense = [PSCustomObject]@{
    Name          = "opnsense"
    Generation    = 2
    CPUCount      = 2
    VRAMBytes     = 4GB
    Path          = "V:\Kiformatou\opnsense"
    VHDPath       = "V:\Kiformatou\opnsense\opnsense.vhdx"
    VHDSizeBytes  = 16GB
    SwitchNameWAN = "INTERNET"
    SwitchNameLAN = "KIFORMATOU"
    ISOPath       = "V:\ISO\opnsense-26.7.iso"
}

# Create the VM directory
New-Item -ItemType Directory -Path $OPNsense.Path -Force | Out-Null

# Create a Generation 2 VM with 4 GB RAM and a 64 GB virtual disk
New-VM -Name $OPNsense.Name `
    -Generation $OPNsense.Generation `
    -MemoryStartupBytes $OPNsense.VRAMBytes `
    -Path $OPNsense.Path `
    -NewVHDPath $OPNsense.VHDPath `
    -NewVHDSizeBytes $OPNsense.VHDSizeBytes `
    -SwitchName $OPNsense.SwitchNameWAN

# Assign 2 virtual processors and disable secure boot
Set-VMProcessor -VMName $OPNsense.Name -Count $OPNsense.CPUCount
Set-VMFirmware -VMName $OPNsense.Name -EnableSecureBoot Off

# Attach the installation ISO and boot from it
$dvdDrive = Add-VMDvdDrive -VMName $OPNsense.Name -Path $OPNsense.ISOPath -Passthru
Set-VMFirmware -VMName $OPNsense.Name -FirstBootDevice $dvdDrive

# Disable dynamic memory
Set-VMMemory -VMName $OPNsense.Name -DynamicMemoryEnabled $false -StartupBytes @OPNsense.VRAMBytes

# Add a second vNIC for LAN
Add-VMNetworkAdapter -VMName $OPNsense.Name `
    -Name $OPNsense.SwitchNameLAN `
    -SwitchName $OPNsense.SwitchNameLAN

# Active Trunk for VLANs 10, 20 and 30
Set-VMNetworkAdapterVlan -VMName $OPNsense.Name `
  -VMNetworkAdapterName $OPNsense.SwitchNameLAN `
  -Trunk -AllowedVlanIdList "10,20,30" -NativeVlanId 0


# Display the VM status
Get-VM -Name $OPNsense.Name
Get-VMNetworkAdapterVlan -VMName $OPNsense.Name
