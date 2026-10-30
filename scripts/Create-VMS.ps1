# Change VMSPath to match an existing drive on your host.

# === Configuration ===
$VMSPath = "V:\Kiformatou"

$VMOPNsense = [PSCustomObject]@{
    Name       = "opnsense"
    Generation = 2
    RamBytes   = 4GB
    Path       = $VMSPath
    VHDBytes   = 8GB
    SwitchName = "INTERNET"
}

$VMProxmox = [PSCustomObject]@{
    Name       = "pve"
    Generation = 2
    RamBytes   = 20GB
    Path       = $VMSPath
    VHDBytes   = 300GB
    SwitchName = "KIFORMATOU"
}

$VMS = @($VMOPNsense, $VMProxmox)

# === Create the VM storage directory if it does not exist.
New-Item -ItemType Directory -Path $VMSPath -Force `
    -ErrorAction Stop | Out-Null

# === Initialize Hyper-V and the storage directory ===
try {
    Import-Module Hyper-V -ErrorAction Stop

    New-Item -ItemType Directory -Path $VMSPath -Force `
        -ErrorAction Stop | Out-Null

    $ExistingVMs = @(Get-VM -ErrorAction Stop)
}
catch {
    throw "Initialization failed: $($_.Exception.Message)"
}

# === Check and create Hyper-V VMs ===
foreach ($VM in $VMS) {
    try {
        # Skip existing VMs without changing their configuration or power state.
        if ($ExistingVMs | Where-Object { $_.Name -eq $VM.Name }) {
            Write-Host "VM '$($VM.Name)' already exists: skipping."
            continue
        }

        # Verify that the required virtual switch exists.
        Get-VMSwitch -Name $VM.SwitchName -ErrorAction Stop | Out-Null

        $VHDPath = Join-Path -Path $VM.Path `
            -ChildPath "$($VM.Name).vhdx" `
            -ErrorAction Stop

        # Preserve any existing virtual disk.
        if (Test-Path -LiteralPath $VHDPath -ErrorAction Stop) {
            throw "Disk '$VHDPath' already exists. VM creation cancelled."
        }

        $Parameters = @{
            Name               = $VM.Name
            Generation         = $VM.Generation
            MemoryStartupBytes = $VM.RamBytes
            Path               = $VM.Path
            NewVHDPath         = $VHDPath
            NewVHDSizeBytes     = $VM.VHDBytes
            SwitchName         = $VM.SwitchName
            ErrorAction        = "Stop"
        }

        New-VM @Parameters | Out-Null

        Write-Host "VM '$($VM.Name)' created and left powered off."
    }
    catch {
        Write-Warning "Failed to create VM '$($VM.Name)': $($_.Exception.Message)"
    }
}

# Do not start the VMs.
