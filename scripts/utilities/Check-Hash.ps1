# === Configuration ===
$PVE = [PSCustomObject]@{
    filePath      = "V:\ISO\pve_8.4-1.iso"
    sha256Expected = "d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"
}

$Fedora44 = [PSCustomObject]@{
    filePath = "V:\ISO\fedora44-1.7.iso"
    sha256Expected = "1620295f6a00c27c3208f0c00b8ece4eab1ec69b9002152d97488bf26a426ddf"
}

# === Checks sum ===
if ((Get-FileHash -LiteralPath $Fedora44.filePath -Algorithm SHA256).Hash -eq $Fedora44.sha256Expected.Trim()) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "ERROR" -ForegroundColor Red
}
