# === CONFIG ===
$teamsCsv = "C:\Users\Lynden.DeLaCruz\Cloud Direct\Network Site Info Update - Asset Register\JCL-VM-Asset-Register-Jan2025.csv"
$repoCsv  = "C:\Repos\site-information-data\JCL-VM-Asset-Register-Jan2025.csv"
$repoPath = "C:\Repos\site-information-data"

# Track last hash to avoid unnecessary commits
$lastHash = ""

Write-Host "Watching for CSV updates..." -ForegroundColor Cyan

while ($true) {
    if (Test-Path $teamsCsv) {

        # Compute hash of Teams CSV
        $currentHash = (Get-FileHash $teamsCsv).Hash

        if ($currentHash -ne $lastHash) {
            Write-Host "Change detected — syncing to GitHub..." -ForegroundColor Green

            # Copy updated CSV into repo
            Copy-Item $teamsCsv $repoCsv -Force

            # Commit + push
            Set-Location $repoPath
            git add .
            git commit -m "Auto-sync CSV update from Teams"
            git push

            Write-Host "Synced at $(Get-Date)" -ForegroundColor Yellow

            # Update last hash
            $lastHash = $currentHash
        }
    }

    Start-Sleep -Seconds 5
}