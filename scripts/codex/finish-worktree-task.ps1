[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$CommitMessage,

    [string]$TargetBranch = "main",

    [string]$TargetWorktreePath,

    [switch]$Merge
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

function Invoke-GitInPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    Push-Location $Path
    try {
        Invoke-Git -Arguments $Arguments
    }
    finally {
        Pop-Location
    }
}

function Get-CurrentBranchName {
    $branchOutput = & git branch --show-current
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to determine the current branch."
    }

    if ($null -eq $branchOutput) {
        return ""
    }

    $branchName = ($branchOutput | Out-String).Trim()
    return $branchName
}

function Get-StatusLines {
    $statusLines = & git status --short
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read git status."
    }

    if ($null -eq $statusLines) {
        return @()
    }

    return @($statusLines)
}

function Test-HasStagedChanges {
    & git diff --cached --quiet --exit-code
    if ($LASTEXITCODE -eq 0) {
        return $false
    }

    if ($LASTEXITCODE -eq 1) {
        return $true
    }

    throw "Unable to determine whether staged changes exist."
}

function Get-WorktreePathForBranch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BranchName
    )

    $raw = & git worktree list --porcelain
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to enumerate git worktrees."
    }

    $currentPath = $null
    foreach ($line in $raw) {
        if ($line.StartsWith("worktree ")) {
            $currentPath = $line.Substring(9)
            continue
        }

        if ($line -eq "branch refs/heads/$BranchName") {
            return $currentPath
        }
    }

    return $null
}

$currentBranch = Get-CurrentBranchName
if ([string]::IsNullOrWhiteSpace($currentBranch)) {
    throw "Current worktree is in detached HEAD. Run scripts/codex/start-worktree-task.ps1 first."
}

$currentPath = (Get-Location).Path
$statusLines = Get-StatusLines

if ($statusLines.Count -gt 0) {
    if ($PSCmdlet.ShouldProcess($currentPath, "Stage all repo changes except ignored files")) {
        Invoke-Git -Arguments @("add", "-A")
    }

    if (Test-HasStagedChanges) {
        if ($PSCmdlet.ShouldProcess($currentBranch, "Create commit '$CommitMessage'")) {
            Invoke-Git -Arguments @("commit", "-m", $CommitMessage)
        }
    }
    else {
        Write-Host "No staged changes were produced after git add -A. Skipping commit."
    }
}
else {
    Write-Host "Working tree is clean. Skipping commit."
}

if (-not $Merge) {
    Write-Host "Finalize complete for branch '$currentBranch'."
    exit 0
}

if ([string]::IsNullOrWhiteSpace($TargetWorktreePath)) {
    $TargetWorktreePath = Get-WorktreePathForBranch -BranchName $TargetBranch
}

if ([string]::IsNullOrWhiteSpace($TargetWorktreePath)) {
    throw "Could not find a worktree currently checked out on branch '$TargetBranch'."
}

Push-Location $TargetWorktreePath
try {
    $targetStatus = Get-StatusLines
}
finally {
    Pop-Location
}

if ($targetStatus.Count -gt 0) {
    throw "Target worktree '$TargetWorktreePath' is not clean. Commit or stash there before merging."
}

if ($PSCmdlet.ShouldProcess($TargetWorktreePath, "Merge '$currentBranch' into '$TargetBranch' with --ff-only")) {
    Invoke-GitInPath -Path $TargetWorktreePath -Arguments @("merge", "--ff-only", $currentBranch)
    Write-Host "Merged '$currentBranch' into '$TargetBranch' at '$TargetWorktreePath'."
}
