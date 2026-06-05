# Setup-HomeMap.ps1
# Creates a home directory structure with logs, scripts, and temp subfolders.
# A dated log file is created automatically in the logs subfolder.

# Creates C:\<Name> with logs, scripts, and temp subfolders.
# Throws if the folder already exists or access is denied.
function New-HomeMap {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    #Define paths
    $baseDir    = Join-Path -Path "C:\" -ChildPath $Name
    $logsDir    = Join-Path -Path $baseDir -ChildPath "logs"
    $scriptsDir = Join-Path -Path $baseDir -ChildPath "scripts"
    $tempDir    = Join-Path -Path $baseDir -ChildPath "temp"

    $logDate    = Get-Date -Format "yyyy-MM-dd"
    $logFile    = Join-Path -Path $logsDir -ChildPath "log $logDate.txt"

    #Check if base directory already exists
    try {
        if (Test-Path -Path $baseDir) {
            throw [System.IO.IOException]::new("A folder named '$Name' already exists at C:\$Name")
        }
    }
    catch [System.IO.IOException] {
        Write-Host ""
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Rename or delete it first, then re-run the script." -ForegroundColor Yellow
        Write-Host ""
        return
    }

    #Create directories
    $dirs = @($baseDir, $logsDir, $scriptsDir, $tempDir)

    foreach ($dir in $dirs) {
        try {
            New-Item -ItemType Directory -Path $dir -ErrorAction Stop | Out-Null
            Write-Host "Created folder : $dir" -ForegroundColor Green
        }
        catch [System.UnauthorizedAccessException] {
            Write-Host ""
            Write-Host "  [ERROR] Access denied: $dir" -ForegroundColor Red
            Write-Host "  Try running the script as Administrator." -ForegroundColor Yellow
            Write-Host ""
            return
        }
        catch {
            Write-Host ""
            Write-Host "  [ERROR] Could not create folder '$dir': $_" -ForegroundColor Red
            Write-Host ""
            return
        }
    }

    #Create log file
    try {
        $logContent = @"
Log file created  : $logDate
Home directory    : $baseDir
Created by script : Setup-HomeMap.ps1

--- Log entries ---
"@
        $logContent | Out-File -FilePath $logFile -Encoding UTF8 -ErrorAction Stop
        Write-Host "Created log file : $logFile" -ForegroundColor Green
    }
    catch [System.UnauthorizedAccessException] {
        Write-Host ""
        Write-Host "  [ERROR] Access denied when creating log file: $logFile" -ForegroundColor Red
        Write-Host "  Try running the script as Administrator." -ForegroundColor Yellow
        Write-Host ""
        return
    }
    catch {
        Write-Host ""
        Write-Host "  [ERROR] Could not create log file '$logFile': $_" -ForegroundColor Red
        Write-Host ""
        return
    }

    #Summary
    Write-Host ""
    Write-Host "Done! Directory structure for '$Name':" -ForegroundColor Cyan
    Write-Host "  $baseDir"
    Write-Host "  ├── logs"
    Write-Host "  │   └── log $logDate.txt"
    Write-Host "  ├── scripts"
    Write-Host "  └── temp"
    Write-Host ""
}

#Entry point 
try {
    $name = Read-Host "Enter a name for the home directory"

    if ([string]::IsNullOrWhiteSpace($name)) {
        throw [System.ArgumentException]::new("No name provided.")
    }

    New-HomeMap -Name $name
}
catch [System.ArgumentException] {
    Write-Host ""
    Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}
catch {
    Write-Host ""
    Write-Host "  [ERROR] Unexpected error: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}