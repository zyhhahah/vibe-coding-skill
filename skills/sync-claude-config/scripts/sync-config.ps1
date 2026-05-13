param(
    [switch]$Setup,
    [switch]$Push,
    [switch]$Pull,
    [switch]$DryRun,
    [string]$Message,
    [string]$RepoPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Text)
    Write-Host "[sync-config] $Text"
}

function Invoke-Git {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    function Format-Argument {
        param([string]$Argument)
        if ([string]::IsNullOrEmpty($Argument)) { return '""' }
        if ($Argument -notmatch '[\s"]') { return $Argument }
        $escaped = $Argument.Replace('"', '\"')
        return '"' + $escaped + '"'
    }

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "git"
    $startInfo.Arguments = ($Arguments | ForEach-Object { Format-Argument -Argument $_ }) -join " "
    $startInfo.WorkingDirectory = $repoRoot
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo

    try {
        $null = $process.Start()
        $stdoutText = $process.StandardOutput.ReadToEnd()
        $stderrText = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        if ($process.ExitCode -ne 0) {
            $joinedArgs = $Arguments -join " "
            $details = if ([string]::IsNullOrWhiteSpace($stderrText)) { $stdoutText } else { $stderrText }
            throw "git $joinedArgs failed with exit code $($process.ExitCode).`n$details"
        }

        if (-not [string]::IsNullOrWhiteSpace($stderrText)) {
            $stderrText.TrimEnd().Split([Environment]::NewLine) | ForEach-Object {
                if (-not [string]::IsNullOrWhiteSpace($_)) { Write-Host $_ }
            }
        }

        if ([string]::IsNullOrWhiteSpace($stdoutText)) { return @() }
        return @($stdoutText.TrimEnd().Split([Environment]::NewLine))
    }
    finally {
        $process.Dispose()
    }
}

function Get-RepoSKills {
    param([string]$Root)
    $skills = @()
    $skillDirs = Get-ChildItem -Path $Root -Directory -Recurse -Depth 2 | Where-Object {
        Test-Path (Join-Path $_.FullName "SKILL.md")
    }
    foreach ($dir in $skillDirs) {
        $skills += [pscustomobject]@{
            Name = $dir.Name
            Path = $dir.FullName
        }
    }
    return $skills
}

function Test-IsGitClean {
    $lines = Invoke-Git -Arguments @("status", "--porcelain")
    return $lines.Count -eq 0
}

function Contains-Secrets {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) { return $false }
    $content = Get-Content $FilePath -Raw
    $patterns = @('-----BEGIN.*PRIVATE KEY-----', 'sk-[A-Za-z0-9]{20,}', 'ghp_[A-Za-z0-9]{20,}')
    foreach ($pat in $patterns) {
        if ($content -match $pat) { return $true }
    }
    return $false
}

# --- Path resolution ---
$claudeHome = Join-Path $env:USERPROFILE ".claude"
$claudeSettings = Join-Path $claudeHome "settings.json"
$claudeSkills = Join-Path $claudeHome "skills"

$knownPaths = @(
    Join-Path $env:USERPROFILE "Downloads\skills-main\skills-main\vibe-coding-skill",
    Join-Path $env:USERPROFILE "vibe-coding-skill"
)

if ($RepoPath) {
    $repoRoot = $RepoPath
} else {
    $repoRoot = $null
    foreach ($p in $knownPaths) {
        if (Test-Path (Join-Path $p ".git")) {
            $repoRoot = $p
            break
        }
    }
    if (-not $repoRoot) {
        # Follow the symlink of this script's own skill to find the repo
        $thisSkillLink = Join-Path $claudeSkills "sync-claude-config"
        if (Test-Path $thisSkillLink) {
            $linkTarget = (Get-Item $thisSkillLink).Target
            if ($linkTarget) {
                $repoRoot = Split-Path -Parent (Split-Path -Parent $linkTarget)
            }
        }
    }
}

if (-not $repoRoot) {
    Write-Error "[sync-config] Could not locate the vibe-coding-skill repository. Use -RepoPath to specify it."
    exit 1
}

$repoConfigDir = Join-Path $repoRoot "claude-config"
$repoSettingsFile = Join-Path $repoConfigDir "settings.json"

# --- Validate mode ---
$switches = @($Setup.IsPresent, $Push.IsPresent, $Pull.IsPresent)
$modeCount = @($switches | Where-Object { $_ }).Count
if ($modeCount -gt 1) {
    Write-Error "[sync-config] Only one of -Setup, -Push, -Pull may be specified at a time."
    exit 1
}
if ($modeCount -eq 0) {
    Write-Error "[sync-config] One of -Setup, -Push, -Pull must be specified."
    exit 1
}

try {
    Push-Location $repoRoot

    # ============================================================
    # SETUP
    # ============================================================
    if ($Setup) {
        Write-Step "Setup mode"

        # Clone repo if it doesn't exist
        if (-not (Test-Path (Join-Path $repoRoot ".git"))) {
            $cloneUrl = "https://github.com/zyhhahah/vibe-coding-skill.git"
            Write-Step "Cloning $cloneUrl into $repoRoot"
            if (-not $DryRun) {
                git clone $cloneUrl $repoRoot 2>&1 | ForEach-Object { Write-Host $_ }
            } else {
                Write-Host "  Would run: git clone $cloneUrl $repoRoot"
            }
        } else {
            Write-Step "Repository already exists at $repoRoot"
        }

        # Discover all skills in the repo
        $skills = Get-RepoSKills -Root (Join-Path $repoRoot "skills")
        Write-Step "Found $(@($skills).Count) skills in repository"

        foreach ($skill in $skills) {
            $linkPath = Join-Path $claudeSkills $skill.Name

            if (Test-Path $linkPath) {
                $item = Get-Item $linkPath -ErrorAction SilentlyContinue
                $isLink = $item.LinkType -eq "SymbolicLink" -or $item.LinkType -eq "Junction"
                if ($isLink -and $item.Target -eq $skill.Path) {
                    Write-Host "  OK: $($skill.Name) (already linked)"
                    continue
                }
                if ($isLink) {
                    Write-Host "  UPDATE: $($skill.Name) ($($item.Target) -> $($skill.Path))"
                    if (-not $DryRun) {
                        Remove-Item $linkPath -Force
                        New-Item -ItemType Junction -Path $linkPath -Target $skill.Path | Out-Null
                    }
                    continue
                }
                Write-Host "  SKIP: $($skill.Name) (path exists but is not a symlink)"
                continue
            }

            Write-Host "  CREATE: $($skill.Name) -> $($skill.Path)"
            if (-not $DryRun) {
                New-Item -ItemType Junction -Path $linkPath -Target $skill.Path | Out-Null
            }
        }

        Write-Step "Setup complete."
        exit 0
    }

    # ============================================================
    # PUSH
    # ============================================================
    if ($Push) {
        Write-Step "Push mode"
        Write-Step "Repository: $repoRoot"

        if (-not (Test-Path $claudeSettings)) {
            Write-Error "[sync-config] No settings.json found at $claudeSettings"
            exit 1
        }

        if (Contains-Secrets -FilePath $claudeSettings) {
            Write-Error "[sync-config] settings.json may contain secrets (API keys, tokens). Aborting for safety."
            exit 1
        }

        # Create claude-config directory if needed
        if (-not (Test-Path $repoConfigDir)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Force -Path $repoConfigDir | Out-Null
            }
            Write-Step "Created claude-config directory"
        }

        # Copy settings.json
        Write-Step "Copying settings.json to repo"
        if (-not $DryRun) {
            Copy-Item $claudeSettings $repoSettingsFile -Force
        } else {
            Write-Host "  Would copy: $claudeSettings -> $repoSettingsFile"
        }

        # Check git status
        $statusLines = Invoke-Git -Arguments @("status", "--porcelain")
        if (@($statusLines).Count -eq 0) {
            Write-Step "No changes to sync."
            exit 0
        }

        Write-Step "Changes to sync:"
        foreach ($line in $statusLines) {
            Write-Host "  $line"
        }

        # Commit message
        if ([string]::IsNullOrWhiteSpace($Message)) {
            $Message = "Sync Claude config: settings.json"
        }

        if ($DryRun) {
            Write-Step "Dry run enabled."
            Write-Host "  Would run: git add --all"
            Write-Host "  Would run: git commit -m `"$Message`""
            Write-Host "  Would run: git push origin HEAD"
            exit 0
        }

        Write-Step "Staging changes"
        Invoke-Git -Arguments @("add", "--all") | Out-Null

        Write-Step "Creating commit"
        Invoke-Git -Arguments @("commit", "-m", $Message) | ForEach-Object { Write-Host $_ }

        Write-Step "Pushing to origin"
        Invoke-Git -Arguments @("push", "origin", "HEAD") | ForEach-Object { Write-Host $_ }

        $shortSha = (Invoke-Git -Arguments @("rev-parse", "--short", "HEAD") | Select-Object -First 1).Trim()
        Write-Step "Sync complete at commit $shortSha"
        exit 0
    }

    # ============================================================
    # PULL
    # ============================================================
    if ($Pull) {
        Write-Step "Pull mode"
        Write-Step "Repository: $repoRoot"

        if ($DryRun) {
            Write-Host "  Would run: git pull"
        } else {
            Write-Step "Pulling latest from origin"
            Invoke-Git -Arguments @("pull") | ForEach-Object { Write-Host $_ }
        }

        # Discover skills and create symlinks for any not already linked
        $skills = Get-RepoSKills -Root (Join-Path $repoRoot "skills")
        $newCount = 0

        foreach ($skill in $skills) {
            $linkPath = Join-Path $claudeSkills $skill.Name
            if (-not (Test-Path $linkPath)) {
                Write-Host "  NEW: $($skill.Name)"
                if (-not $DryRun) {
                    New-Item -ItemType Junction -Path $linkPath -Target $skill.Path | Out-Null
                }
                $newCount++
            }
        }

        if ($newCount -eq 0) {
            Write-Step "All skills are already linked."
        } else {
            Write-Step "Linked $newCount new skill(s)."
        }

        # Offer to restore settings.json (only if user explicitly confirms via agent)
        if (Test-Path $repoSettingsFile) {
            Write-Host ""
            Write-Host "  Repo has settings.json at: $repoSettingsFile"
            Write-Host "  To restore it to .claude/settings.json, re-run with: -Pull -RestoreSettings"
            Write-Host "  (Agent should confirm with user before restoring)"
        }

        Write-Step "Pull complete."
        exit 0
    }
}
catch {
    Write-Error "[sync-config] $($_.Exception.Message)"
    exit 1
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
}
