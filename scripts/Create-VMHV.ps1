# Create the VM directory
New-Item -ItemType Directory -Path "V:\Kiformatou\opnsense" -Force | Out-Null

# Create a Generation 2 VM with 4 GB RAM and a 64 GB virtual disk
New-VM -Name opnsense `
    -Generation 2 `
    -MemoryStartupBytes 4GB `
    -Path "V:\Kiformatou\opnsense" `
    -NewVHDPath "V:\Kiformatou\opnsense\opnsense.vhdx" `
    -NewVHDSizeBytes 8GB `
    -SwitchName "INTERNET"

# Assign 2 virtual processors and disable secure boot
Set-VMProcessor -VMName "opnsense" -Count 2
Set-VMFirmware -VMName "opnsense" -EnableSecureBoot Off

# Attach the installation ISO and boot from it
$dvdDrive = Add-VMDvdDrive -VMName "opnsense" -Path "V:\ISO\opnsense-26.7.iso" -Passthru
Set-VMFirmware -VMName "opnsense" -FirstBootDevice $dvdDrive

# Disable dynamic memory
Set-VMMemory -VMName "opnsense" -DynamicMemoryEnabled $false -StartupBytes 4GB

# Add a second vNIC
Add-VMNetworkAdapter -VMName "opnsense" `
    -Name "KIFORMATOU" `
    -SwitchName "KIFORMATOU"

# Display the VM status
Get-VM -Name "opnsense"
