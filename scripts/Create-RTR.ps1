$vmName = "opnsense"
$vmDirectory = "V:\Kiformatou\$vmName"
$isoPath = "V:\ISO\opnsense-26.7.iso"
$switchWAN = "INTERNET"
$switchLAN = "KIFORMATOU"

# Create the VM directory
New-Item -ItemType Directory -Path "V:\Kiformatou\$vmName" -Force | Out-Null

# Create a Generation 2 VM with 4 GB RAM and a 64 GB virtual disk
New-VM -Name $vmName `
    -Generation 2 `
    -MemoryStartupBytes 4GB `
    -Path $vmDirectory `
    -NewVHDPath "$vmDirectory\$vmName.vhdx" `
    -NewVHDSizeBytes 8GB `
    -SwitchName $switchWAN

# Assign 2 virtual processors
Set-VMProcessor -VMName $vmName -Count 2

# Attach the installation ISO and boot from it
$dvdDrive = Add-VMDvdDrive -VMName $vmName -Path $isoPath -Passthru
Set-VMFirmware -VMName $vmName -FirstBootDevice $dvdDrive

# Disable dynamic memory
Set-VMMemory -VMName $vmName -DynamicMemoryEnabled $false -StartupBytes 4GB

# Add a second vNIC
Add-VMNetworkAdapter -VMName $vmName `
    -Name $switchLAN `
    -SwitchName $switchLAN

# Display the VM status
Get-VM -Name $vmName
