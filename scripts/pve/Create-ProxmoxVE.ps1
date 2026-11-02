# Configuration
$PVE = [PSCustomObject]@{
    Name         = "pve"
    Generation   = 2
    CPUCount     = 6
    VRAMBytes    = 20GB
    Path         = "V:\Kiformatou\pve"
    VHDPath      = "V:\Kiformatou\pve\pve.vhdx"
    VHDSizeBytes = 300GB
    SwitchName   = "KIFORMATOU"
    ISOPath      = "V:\ISO\pve_8.4-1.iso"
}

# Create the VM directory
New-Item -ItemType Directory -Path $PVE.Path -Force | Out-Null

# Create a Generation 2 VM with 20 GB vRAM and a 300 GB vHD
New-VM -Name $PVE.Name `
    -Generation $PVE.Generation `
    -MemoryStartupBytes $PVE.VRAMBytes `
    -Path $PVE.Path `
    -NewVHDPath $PVE.VHDPath `
    -NewVHDSizeBytes $PVE.VHDSizeBytes `
    -SwitchName $PVE.SwitchName

# Assign 6 vCPU
Set-VMProcessor -VMName $PVE.Name -Count $PVE.CPUCount

# Disable secure boot
Set-VMFirmware -VMName $PVE.Name -EnableSecureBoot Off

# Activate exposed virtualization
Set-VMProcessor -VMName $PVE.Name -ExposeVirtualizationExtensions $true

# Allow tagged VLANs 10 and 20
Get-VMNetworkAdapter -VMName $PVE.Name |
    Set-VMNetworkAdapterVlan -Trunk `
        -AllowedVlanIdList "10,20,30" `
        -NativeVlanId 0

# Allow traffic from nested VM MAC addresses
Get-VMNetworkAdapter -VMName $PVE.Name |
    Set-VMNetworkAdapter -MacAddressSpoofing On


# Attach the installation ISO and boot from it
$dvdDrive = Add-VMDvdDrive -VMName $PVE.Name -Path $PVE.ISOPath -Passthru
Set-VMFirmware -VMName $PVE.Name -FirstBootDevice $dvdDrive

# Disable dynamic memory
Set-VMMemory -VMName $PVE.Name -DynamicMemoryEnabled $false -StartupBytes $PVE.VRAMBytes

# Display the VM status
Get-VM -Name $PVE.Name
Get-VMProcessor -VMName $PVE.Name |
    Select-Object VMName, ExposeVirtualizationExtensions
