# ============================
# CONFIG
# ============================
$teamsCsv = "C:\Users\$env:USERNAME\Cloud Direct\Network Site Info Update - Asset Register\JCL-VM-Asset-Register-Jan2025.csv"
$repoCsv  = "C:\Repos\site-information-data\JCL-VM-Asset-Register-Jan2025.csv"
$repoPath = "C:\Repos\site-information-data"

Write-Host "Starting smart sync engine..."
Write-Host "Checking for pre-existing differences..."

# ============================
# FUNCTION: Sync to GitHub
# ============================
function Sync-ToGitHub {
    Write-Host "Syncing to GitHub..."

    Copy-Item -Path $teamsCsv -Destination $repoCsv -Force

    Set-Location $repoPath
    git add .
    git commit -m "Auto-sync CSV update from Teams"
    git push

    Write-Host "Synced at $(Get-Date)"
}

# ============================
# STEP 1: Smart startup sync
# ============================
if (-not (Test-Path $teamsCsv)) {
    Write-Host "Teams CSV not found. Waiting for file..."
} else {
    if (-not (Test-Path $repoCsv)) {
        Write-Host "Repo CSV missing — copying initial file..."
        Sync-ToGitHub
    } else {
        $teamsHash = Get-FileHash $teamsCsv
        $repoHash  = Get-FileHash $repoCsv

        if ($teamsHash.Hash -ne $repoHash.Hash) {
            Write-Host "Detected difference on startup — syncing now..."
            Sync-ToGitHub
        } else {
            Write-Host "No differences found — repo is already up to date."
        }
    }
}

# ============================
# STEP 2: Live watcher
# ============================
Write-Host "Watching for CSV updates..."

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = Split-Path $teamsCsv
$watcher.Filter = (Split-Path $teamsCsv -Leaf)
$watcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite'

Register-ObjectEvent $watcher Changed -Action {
    Start-Sleep -Milliseconds 500
    Write-Host "Change detected — syncing..."
    Sync-ToGitHub
}

while ($true) { Start-Sleep 1 }