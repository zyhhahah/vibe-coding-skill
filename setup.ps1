# Bootstrap script for vibe-coding-skill on a new machine.
# Usage: git clone https://github.com/zyhhahah/vibe-coding-skill.git && cd vibe-coding-skill && .\setup.ps1
param(
    [switch]$DryRun,
    [switch]$RestoreSettings
)

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path $scriptRoot).Path
$claudeHome = Join-Path $env:USERPROFILE ".claude"
$claudeSkills = Join-Path $claudeHome "skills"
$claudeSettings = Join-Path $claudeHome "settings.json"
$repoSettings = Join-Path $repoRoot "claude-config\settings.json"

Write-Host "=== Vibe Coding Skills Setup ==="
Write-Host "Repo: $repoRoot"
Write-Host ""

# 1. Create .claude directories
foreach ($dir in @($claudeHome, $claudeSkills)) {
    if (-not (Test-Path $dir)) {
        Write-Host "CREATE: $dir"
        if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    }
}

# 2. Discover and link all skills
$skillDirs = Get-ChildItem -Path (Join-Path $repoRoot "skills") -Directory -Recurse -Depth 2 | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
}

Write-Host "Found $($skillDirs.Count) skills"
Write-Host ""

foreach ($dir in $skillDirs) {
    $linkPath = Join-Path $claudeSkills $dir.Name

    if (Test-Path $linkPath) {
        $item = Get-Item $linkPath -ErrorAction SilentlyContinue
        $isLink = $item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction"
        if ($isLink -and $item.Target -eq $dir.FullName) {
            Write-Host "  OK: $($dir.Name)"
        } elseif ($isLink) {
            Write-Host "  UPDATE: $($dir.Name)"
            if (-not $DryRun) {
                Remove-Item $linkPath -Force
                New-Item -ItemType Junction -Path $linkPath -Target $dir.FullName | Out-Null
            }
        } else {
            Write-Host "  SKIP: $($dir.Name) (not a link)"
        }
    } else {
        Write-Host "  NEW: $($dir.Name)"
        if (-not $DryRun) {
            New-Item -ItemType Junction -Path $linkPath -Target $dir.FullName | Out-Null
        }
    }
}

Write-Host ""

# 3. Optionally restore settings.json
if ($RestoreSettings) {
    if (Test-Path $repoSettings) {
        if (Test-Path $claudeSettings) {
            Write-Host "Local settings.json already exists. Use -RestoreSettings -Force to overwrite."
        } else {
            Write-Host "Restoring settings.json from repo"
            if (-not $DryRun) {
                Copy-Item $repoSettings $claudeSettings
            } else {
                Write-Host "  Would copy: $repoSettings -> $claudeSettings"
            }
        }
    } else {
        Write-Host "No settings.json in repo yet. Run 'sync-claude-config -Push' from your main machine first."
    }
} elseif (Test-Path $repoSettings) {
    Write-Host "Repo has settings.json. Re-run with -RestoreSettings to restore it."
} else {
    Write-Host "No settings.json in repo. On your main machine, run: sync-claude-config -Push"
}

Write-Host ""
Write-Host "Setup complete."
if ($DryRun) {
    Write-Host "(Dry run -- no changes were made)"
}
