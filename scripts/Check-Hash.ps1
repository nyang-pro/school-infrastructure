# === Configuration ===
$file = "C:\ISO\ipfire-2.29.iso"
$sha256Expected = "1932479ca0022bf151030d4aacbbe98d29030730546b06a87d13b306c3b47c9d"

# === Checks sum ===
if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -eq $sha256Expected.Trim()) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "ERROR" -ForegroundColor Red
}
