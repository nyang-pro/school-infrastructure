# === Configuration ===
$LanSwitch = [PSCustomObject]@{
    Name       = "KIFORMATOU"
    SwitchType = "Internal"
}

$WanSwitch = [PSCustomObject]@{
    Name           = "INTERNET"
    SwitchType     = "External"
    NetAdapterName = "Ethernet"
}

$Switches = @($LanSwitch, $WanSwitch)

# === Check and create switches ===
foreach ($Config in $Switches) {
    try {
        $ExistingSwitch = Get-VMSwitch -ErrorAction Stop |
            Where-Object Name -EQ $Config.Name

        if ($null -ne $ExistingSwitch) {
            if ($ExistingSwitch.SwitchType.ToString() -ne $Config.SwitchType) {
                Write-Host `
                    "Switch '$($Config.Name)' uses $($ExistingSwitch.SwitchType) mode; expected $($Config.SwitchType)." `
                    -ForegroundColor Red
                continue
            }

            if ($Config.SwitchType -eq "External") {
                $Adapter = Get-NetAdapter `
                    -Name $Config.NetAdapterName `
                    -ErrorAction Stop

                $CorrectAdapter = (
                    $ExistingSwitch.NetAdapterInterfaceDescription -eq
                    $Adapter.InterfaceDescription
                )

                $HostConnected = $ExistingSwitch.AllowManagementOS -eq $true

                if (-not ($CorrectAdapter -and $HostConnected)) {
                    Write-Host `
                        "Switch '$($Config.Name)' has an incorrect physical adapter or management OS sharing setting." `
                        -ForegroundColor Red
                    continue
                }
            }

            Write-Host `
                "Switch '$($Config.Name)' already exists and is correctly configured." `
                -ForegroundColor Green
            continue
        }

        $Parameters = @{
            Name        = $Config.Name
            ErrorAction = "Stop"
        }

        switch ($Config.SwitchType) {
            "Internal" {
                $Parameters.SwitchType = "Internal"
            }
            "Private" {
                $Parameters.SwitchType = "Private"
            }
            "External" {
                $Parameters.NetAdapterName = $Config.NetAdapterName
                $Parameters.AllowManagementOS = $true
            }
            default {
                throw "Unsupported switch type: $($Config.SwitchType)"
            }
        }

        New-VMSwitch @Parameters | Out-Null

        Write-Host `
            "Switch '$($Config.Name)' created in $($Config.SwitchType) mode." `
            -ForegroundColor Green
    }
    catch {
        Write-Host `
            "Failed to configure switch '$($Config.Name)': $($_.Exception.Message)" `
            -ForegroundColor Red
    }
}

# === Display switches ===
Get-VMSwitch |
    Format-Table Name, SwitchType, AllowManagementOS
