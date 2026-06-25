# backup-all.ps1 — Backup de todos los proyectos Diligencia
# Uso: .\scripts\backup-all.ps1
# Genera bundles git (para proyectos con git) y metadata en C:\xampp\htdocs\backups\<fecha>\

$date = Get-Date -Format "yyyy-MM-dd"
$backupDir = "C:\xampp\htdocs\backups\$date"

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

$projects = @(
    @{Name="Diligencia";       Path="C:\xampp\htdocs\Diligencia";       Git=$true},
    @{Name="MarketAI";         Path="C:\xampp\htdocs\MarketAI";         Git=$true},
    @{Name="buenobonitobarato";Path="C:\xampp\htdocs\buenobonitobarato";Git=$true},
    @{Name="nemesis";          Path="C:\xampp\htdocs\nemesis";          Git=$true},
    @{Name="+RM";              Path="C:\xampp\htdocs\+RM";              Git=$true},
    @{Name="conquisitare";     Path="C:\xampp\htdocs\conquisitare";     Git=$true}
)

$index = @()

foreach ($p in $projects) {
    Write-Host "Backing up $($p.Name)..." -ForegroundColor Cyan
    
    if ($p.Git -and (Test-Path "$($p.Path)\.git")) {
        $bundle = "$backupDir\$($p.Name)-$date.bundle"
        git -C $p.Path bundle create $bundle --all 2>$null
        if ($LASTEXITCODE -eq 0) {
            $size = (Get-Item $bundle).Length / 1KB
            Write-Host "  ✅ bundle: $([math]::Round($size,1)) KB" -ForegroundColor Green
            $index += "$($p.Name) | bundle | $([math]::Round($size,1)) KB"
        } else {
            # Fallback: zip
            $zip = "$backupDir\$($p.Name)-$date.zip"
            Compress-Archive -Path $p.Path -DestinationPath $zip -Force
            Write-Host "  ⚠️ bundle fallo, zip creado" -ForegroundColor Yellow
            $index += "$($p.Name) | zip (fallback) | ver archivo"
        }
    } else {
        $zip = "$backupDir\$($p.Name)-$date.zip"
        Compress-Archive -Path $p.Path -DestinationPath $zip -Force
        Write-Host "  ⚠️ sin git, zip creado" -ForegroundColor Yellow
        $index += "$($p.Name) | zip | ver archivo"
    }
}

# Metadata index
$index | Out-File "$backupDir\INDEX.txt"
Write-Host "`nBackup completo: $backupDir" -ForegroundColor Green
Write-Host "Proyectos: $($index.Count)" -ForegroundColor Green
