# === Configuration ===
$file = "V:\ISO\pve_8.4-1.iso"
$sha256Expected = "d237d70ca48a9f6eb47f95fd4fd337722c3f69f8106393844d027d28c26523d8"

# === Checks sum ===
if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -eq $sha256Expected.Trim()) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "ERROR" -ForegroundColor Red
}
