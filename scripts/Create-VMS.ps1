#Requires -RunAsAdministrator
#Requires -Modules Hyper-V

$CsvPath = "C:\Kiformatou\vms-hyperv.csv"
$ErrorActionPreference = "Stop"

$rows = Import-Csv -LiteralPath $CsvPath -Delimiter ","

foreach ($row in $rows) {
    try {
        $vmName = $row.VMName.Trim()

        if (Get-VM -Name $vmName -ErrorAction SilentlyContinue) {
            Write-Warning "Skipping '$vmName': VM already exists."
            continue
        }

        $generation = [int]$row.Generation
        $dynamicMemory = [bool]::Parse($row.DynamicMemoryEnabled)
        $secureBoot = [bool]::Parse($row.SecureBootEnabled)
        $startupMemory = [long]([double]$row.StartupMemoryGB * 1GB)

        # Validate dependencies before creating files.
        Get-VMSwitch -Name $row.SwitchName | Out-Null

        if ($row.ISOPath -and
            -not (Test-Path -LiteralPath $row.ISOPath -PathType Leaf)) {
            throw "ISO file not found: $($row.ISOPath)"
        }

        if (Test-Path -LiteralPath $row.VHDPath) {
            throw "Disk already exists: $($row.VHDPath)"
        }

        if ($generation -notin 1, 2) {
            throw "Generation must be 1 or 2."
        }

        if ($generation -eq 1 -and $secureBoot) {
            throw "Secure Boot requires Generation 2."
        }

        $diskFormat = $row.VHDFormat.Trim().ToUpperInvariant()
        $extension = [IO.Path]::GetExtension($row.VHDPath)

        if ($diskFormat -notin "VHD", "VHDX" -or
            $extension -ine ".$diskFormat") {
            throw "VHDFormat must be VHD or VHDX and match the file extension."
        }

        if ($generation -eq 2 -and $diskFormat -ne "VHDX") {
            throw "Generation 2 requires VHDX."
        }

        if ($row.VHDType -notin "Dynamic", "Fixed") {
            throw "VHDType must be Dynamic or Fixed."
        }

        $memoryParameters = @{
            VMName               = $vmName
            DynamicMemoryEnabled = $dynamicMemory
            StartupBytes         = $startupMemory
        }

        if ($dynamicMemory) {
            $minimumMemory = [long]([double]$row.MinimumMemoryGB * 1GB)
            $maximumMemory = [long]([double]$row.MaximumMemoryGB * 1GB)

            if ($minimumMemory -le 0 -or
                $minimumMemory -gt $startupMemory -or
                $startupMemory -gt $maximumMemory) {
                throw "Memory must satisfy: 0 < Minimum <= Startup <= Maximum."
            }

            $memoryParameters.MinimumBytes = $minimumMemory
            $memoryParameters.MaximumBytes = $maximumMemory
        }

        $vlanId = $null

        if (-not [string]::IsNullOrWhiteSpace($row.VLANId)) {
            $vlanId = [int]$row.VLANId

            if ($vlanId -lt 1 -or $vlanId -gt 4094) {
                throw "VLANId must be between 1 and 4094, or empty."
            }
        }

        # Create storage directories.
        $diskDirectory = Split-Path -Path $row.VHDPath -Parent

        foreach ($directory in @($row.ConfigurationPath, $diskDirectory)) {
            New-Item -ItemType Directory -Path $directory -Force |
                Out-Null
        }

        # Create a new virtual disk.
        $diskParameters = @{
            Path      = $row.VHDPath
            SizeBytes = [long]([double]$row.VHDSizeGB * 1GB)
        }

        if ($row.VHDType -eq "Dynamic") {
            New-VHD @diskParameters -Dynamic | Out-Null
        }
        else {
            New-VHD @diskParameters -Fixed | Out-Null
        }

        # Create and configure the VM.
        $vmParameters = @{
            Name               = $vmName
            Path               = $row.ConfigurationPath
            Generation         = $generation
            MemoryStartupBytes = $startupMemory
            VHDPath            = $row.VHDPath
            SwitchName         = $row.SwitchName
        }

        New-VM @vmParameters | Out-Null

        Set-VMProcessor -VMName $vmName -Count ([int]$row.ProcessorCount)
        Set-VMMemory @memoryParameters

        if ($null -ne $vlanId) {
            Set-VMNetworkAdapterVlan -VMName $vmName `
                -Access -VlanId $vlanId
        }

        # Configure Secure Boot for Generation 2.
        if ($generation -eq 2) {
            $firmwareParameters = @{
                VMName           = $vmName
                EnableSecureBoot = "Off"
            }

            if ($secureBoot) {
                $firmwareParameters.EnableSecureBoot = "On"
                $firmwareParameters.SecureBootTemplate = "MicrosoftWindows"

                if ($row.OperatingSystem -match "Linux|Ubuntu|Debian|CentOS|Red Hat|Rocky|Alma|SUSE|Fedora") {
                    $firmwareParameters.SecureBootTemplate =
                        "MicrosoftUEFICertificateAuthority"
                }
            }

            Set-VMFirmware @firmwareParameters
        }

        # Attach installation media and configure DVD boot.
        if ($row.ISOPath) {
            $dvdDrive = Get-VMDvdDrive -VMName $vmName |
                Select-Object -First 1

            if ($null -eq $dvdDrive) {
                $dvdDrive = Add-VMDvdDrive -VMName $vmName `
                    -Path $row.ISOPath -Passthru
            }
            else {
                Set-VMDvdDrive -VMDvdDrive $dvdDrive -Path $row.ISOPath
            }

            if ($generation -eq 2) {
                Set-VMFirmware -VMName $vmName -FirstBootDevice $dvdDrive
            }
            else {
                Set-VMBios -VMName $vmName `
                    -StartupOrder CD, IDE, LegacyNetworkAdapter, Floppy
            }
        }

        Write-Host "Created '$vmName' successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to create '$($row.VMName)': $($_.Exception.Message)"
        Write-Warning "Any partially created VM or disk has been retained for inspection."
    }
}
