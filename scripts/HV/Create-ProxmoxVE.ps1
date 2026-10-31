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
$PVE = [PSCustomObject]@{
    Name          = "pve"
    Generation    = 2
    CPUCount      = 6
    VRAMBytes     = 20GB
    Path          = "V:\Kiformatou\pve"
    VHDPath       = "V:\Kiformatou\pve\pve.vhdx"
    VHDSizeBytes  = 220GB
    SwitchName    = "KIFORMATOU"
    ISOPath       = "V:\ISO\pve_8.4-1.iso"
}

# Create the VM directory
New-Item -ItemType Directory -Path $PVE.Path -Force | Out-Null

# Create a Generation 2 VM with 4 GB RAM and a 64 GB virtual disk
New-VM -Name $PVE.Name `
    -Generation $PVE.Generation `
    -MemoryStartupBytes $PVE.VRAMBytes `
    -Path $PVE.Path `
    -NewVHDPath $PVE.VHDPath `
    -NewVHDSizeBytes $PVE.VHDSizeBytes `
    -SwitchName $PVE.SwitchName

# Assign 2 virtual processors and disable secure boot
Set-VMProcessor -VMName $PVE.Name -Count $PVE.CPUCount
Set-VMFirmware -VMName $PVE.Name -EnableSecureBoot Off

# Attach the installation ISO and boot from it
$dvdDrive = Add-VMDvdDrive -VMName $PVE.Name -Path $PVE.ISOPath -Passthru
Set-VMFirmware -VMName $PVE.Name -FirstBootDevice $dvdDrive

# Disable dynamic memory
Set-VMMemory -VMName $PVE.Name -DynamicMemoryEnabled $false -StartupBytes $PVE.VRAMBytes

# Display the VM status
Get-VM -Name $PVE.Name
