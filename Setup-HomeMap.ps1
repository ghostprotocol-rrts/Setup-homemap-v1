# Setup-HomeMap.ps1
# Creates a home directory structure with logs, scripts, and temp subfolders.
# A dated log file is created automatically in the logs subfolder.

# ── Prompt for name ──────────────────────────────────────────────────────────
$name = Read-Host "Enter a name for the home directory"

if ([string]::IsNullOrWhiteSpace($name)) {
    Write-Error "No name provided. Exiting."
    exit 1
}

# ── Define paths ─────────────────────────────────────────────────────────────
$baseDir    = Join-Path -Path $PSScriptRoot -ChildPath $name
$logsDir    = Join-Path -Path $baseDir -ChildPath "logs"
$scriptsDir = Join-Path -Path $baseDir -ChildPath "scripts"
$tempDir    = Join-Path -Path $baseDir -ChildPath "temp"

$logDate    = Get-Date -Format "yyyy-MM-dd"
$logFile    = Join-Path -Path $logsDir -ChildPath "log $logDate.txt"

# ── Create directories ────────────────────────────────────────────────────────
$dirs = @($baseDir, $logsDir, $scriptsDir, $tempDir)

foreach ($dir in $dirs) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Created folder : $dir" -ForegroundColor Green
    } else {
        Write-Host "Already exists : $dir" -ForegroundColor Yellow
    }
}

# ── Create log file ───────────────────────────────────────────────────────────
$logContent = @"
Log file created  : $logDate
Home directory    : $baseDir
Created by script : Setup-HomeMap.ps1

--- Log entries ---
"@

if (-not (Test-Path -Path $logFile)) {
    $logContent | Out-File -FilePath $logFile -Encoding UTF8
    Write-Host "Created log file : $logFile" -ForegroundColor Green
} else {
    Write-Host "Log file exists  : $logFile" -ForegroundColor Yellow
}

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Done! Directory structure for '$name':" -ForegroundColor Cyan
Write-Host "  $baseDir"
Write-Host "  ├── logs"
Write-Host "  │   └── log $logDate.txt"
Write-Host "  ├── scripts"
Write-Host "  └── temp"