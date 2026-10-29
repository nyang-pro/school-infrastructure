# Variables
$vNIC1 = "WAN"
$vNIC2 = "LAN"

# Main
Write-Host "=== Hyper-V Setup ===" -ForegroundColor Cyan
Write-Host "Création de la vNIC… " -NoNewline

Add-VMNetworkAdapter -VMName "MaVM" -Name "LAN" -SwitchName "vSwitch" -ErrorAction Stop

Write-Host "Terminée" -ForegroundColor Green
