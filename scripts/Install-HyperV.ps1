# Setup
$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction Stop

# === Install Hyper-V ====
Write-Host "=== Hyper-V Installation ===" -ForegroundColor Cyan

if ($feature.State -eq "Enabled") {
    Write-Host "Hyper-V already installed" -ForegroundColor Green
    Get-Service vmms
    Get-CimInstance Win32_ComputerSystem |
        Select-Object HypervisorPresent
    Get-VM
}
elseif ($feature.State -eq "EnablePending") {
    Write-Host "Activation pending. Restart Windows, then run this script again."
}
else {
    $result = Enabled-WindowsOptionalFeature -Online `
        -FeatureName Microsoft-Hyper-V-All -All -NoRestart -ErrorAction Stop

    if ($result.RestartNeeded) {
        Write-Host "Hyper-V enabled. Restart windows, then run this script again"
    }
    else {
        Get-Service vmms

        Get-CimInstance Win32_ComputerSystem |
            Select-Object HypervisorPresent

        Get-VM
    }
}
