param(
    [string]$Message,
    [switch]$DryRun,
    [switch]$OpenRepo
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Text)
    Write-Host "[sync-assets] $Text"
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    function Format-Argument {
        param([string]$Argument)

        if ([string]::IsNullOrEmpty($Argument)) {
            return '""'
        }

        if ($Argument -notmatch '[\s"]') {
            return $Argument
        }

        $escaped = $Argument.Replace('"', '\"')
        return '"' + $escaped + '"'
    }

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "git"
    $startInfo.Arguments = ($Arguments | ForEach-Object { Format-Argument -Argument $_ }) -join " "
    $startInfo.WorkingDirectory = (Get-Location).Path
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
            $details = if ([string]::IsNullOrWhiteSpace($stderrText)) {
                $stdoutText
            } else {
                $stderrText
            }
            throw "git $joinedArgs failed with exit code $($process.ExitCode).`n$details"
        }

        if (-not [string]::IsNullOrWhiteSpace($stderrText)) {
            $stderrText.TrimEnd().Split([Environment]::NewLine) | ForEach-Object {
                if (-not [string]::IsNullOrWhiteSpace($_)) {
                    Write-Host $_
                }
            }
        }

        if ([string]::IsNullOrWhiteSpace($stdoutText)) {
            return @()
        }

        return @($stdoutText.TrimEnd().Split([Environment]::NewLine))
    }
    finally {
        $process.Dispose()
    }
}

function Normalize-ChangedPath {
    param([string]$Path)

    $normalized = $Path.Trim()
    if ($normalized -match " -> ") {
        $normalized = ($normalized -split " -> " | Select-Object -Last 1).Trim()
    }

    return $normalized.Replace("\", "/")
}

function Get-ChangedEntries {
    param([string[]]$StatusLines)

    $entries = @()

    foreach ($line in $StatusLines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $statusCode = if ($line.Length -ge 2) {
            $line.Substring(0, 2).Trim()
        } else {
            $line.Trim()
        }

        if ([string]::IsNullOrWhiteSpace($statusCode)) {
            $statusCode = "?"
        }

        $path = if ($line.Length -gt 3) {
            Normalize-ChangedPath -Path $line.Substring(3)
        } else {
            ""
        }

        $entries += [pscustomobject]@{
            Status = $statusCode
            Path   = $path
        }
    }

    return $entries
}

function Get-DisplayStatus {
    param([string]$StatusCode)

    if ($StatusCode -eq "??") {
        return "new"
    }
    if ($StatusCode.Contains("R")) {
        return "renamed"
    }
    if ($StatusCode.Contains("A")) {
        return "added"
    }
    if ($StatusCode.Contains("D")) {
        return "deleted"
    }
    if ($StatusCode.Contains("M")) {
        return "modified"
    }
    if ($StatusCode.Contains("U")) {
        return "conflicted"
    }

    return $StatusCode
}

function Get-ScopeLabel {
    param([string]$Path)

    if ($Path -eq "README.md") {
        return "docs"
    }

    if ($Path -eq "sync-assets.cmd") {
        return "tooling"
    }

    $topLevel = ($Path -split "/")[0].ToLowerInvariant()

    switch ($topLevel) {
        "skills" { return "skills" }
        "prompts" { return "prompts" }
        "playbooks" { return "playbooks" }
        "templates" { return "templates" }
        "references" { return "references" }
        "tools" { return "tooling" }
        ".github" { return "github" }
        default { return "misc" }
    }
}

function New-CommitMessage {
    param([object[]]$Entries)

    $scopes = New-Object System.Collections.Generic.List[string]

    foreach ($entry in $Entries) {
        $scope = Get-ScopeLabel -Path $entry.Path
        if (-not $scopes.Contains($scope)) {
            $scopes.Add($scope)
        }
    }

    if ($scopes.Count -eq 0) {
        return "Sync AI assets"
    }

    if ($scopes.Count -eq 1) {
        return "Sync AI assets: $($scopes[0])"
    }

    $visibleScopes = $scopes | Select-Object -First 3
    $suffix = if ($scopes.Count -gt 3) {
        " +$($scopes.Count - 3) more"
    } else {
        ""
    }

    return "Sync AI assets: $($visibleScopes -join ", ")$suffix"
}

function Convert-RemoteToWebUrl {
    param([string]$RemoteUrl)

    if ($RemoteUrl.StartsWith("https://") -or $RemoteUrl.StartsWith("http://")) {
        return ($RemoteUrl -replace "\.git$", "")
    }

    if ($RemoteUrl -match "^git@github\.com:(.+?)(\.git)?$") {
        return "https://github.com/$($Matches[1])"
    }

    return $null
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptRoot "..")).Path

try {
    Get-Command git -ErrorAction Stop | Out-Null

    Push-Location $repoRoot

    $detectedRepoRoot = (Invoke-Git -Arguments @("rev-parse", "--show-toplevel") | Select-Object -First 1).Trim()
    $repoRoot = (Resolve-Path $detectedRepoRoot).Path

    $originUrl = (Invoke-Git -Arguments @("remote", "get-url", "origin") | Select-Object -First 1).Trim()
    $currentBranch = (Invoke-Git -Arguments @("rev-parse", "--abbrev-ref", "HEAD") | Select-Object -First 1).Trim()
    $statusLines = Invoke-Git -Arguments @("status", "--porcelain", "--untracked-files=all")

    if ($statusLines.Count -eq 0) {
        Write-Step "No uncommitted changes found."
        exit 0
    }

    $entries = Get-ChangedEntries -StatusLines $statusLines

    Write-Step "Repository root: $repoRoot"
    Write-Step "Remote origin: $originUrl"
    Write-Step "Target branch: $currentBranch"
    Write-Step "Changes to sync:"

    foreach ($entry in $entries) {
        Write-Host ("  - [{0}] {1}" -f (Get-DisplayStatus -StatusCode $entry.Status), $entry.Path)
    }

    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = New-CommitMessage -Entries $entries
    }

    Write-Step "Commit message: $Message"

    if ($DryRun) {
        Write-Step "Dry run enabled."
        Write-Host "  Would run: git add --all"
        Write-Host "  Would run: git commit -m `"$Message`""
        Write-Host "  Would run: git push origin HEAD"
        exit 0
    }

    Write-Step "Staging changes"
    Invoke-Git -Arguments @("add", "--all") | Out-Null

    $stagedFiles = Invoke-Git -Arguments @("diff", "--cached", "--name-only")
    if ($stagedFiles.Count -eq 0) {
        Write-Step "Nothing was staged after git add --all."
        exit 0
    }

    Write-Step "Creating commit"
    Invoke-Git -Arguments @("commit", "-m", $Message) | ForEach-Object { Write-Host $_ }

    Write-Step "Pushing to origin"
    Invoke-Git -Arguments @("push", "origin", "HEAD") | ForEach-Object { Write-Host $_ }

    $shortSha = (Invoke-Git -Arguments @("rev-parse", "--short", "HEAD") | Select-Object -First 1).Trim()
    Write-Step "Sync complete at commit $shortSha"

    if ($OpenRepo) {
        $webUrl = Convert-RemoteToWebUrl -RemoteUrl $originUrl
        if ($null -ne $webUrl) {
            Write-Step "Opening repository page"
            Start-Process $webUrl
        } else {
            Write-Step "Could not derive a browser URL from origin."
        }
    }
}
catch {
    Write-Error "[sync-assets] $($_.Exception.Message)"
    exit 1
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
}
