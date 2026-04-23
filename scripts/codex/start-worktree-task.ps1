[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,

    [string]$BranchPrefix = "codex"
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

function Test-LocalBranchExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BranchName
    )

    & git show-ref --verify --quiet "refs/heads/$BranchName"
    if ($LASTEXITCODE -eq 0) {
        return $true
    }

    if ($LASTEXITCODE -eq 1) {
        return $false
    }

    throw "Unable to determine whether branch '$BranchName' exists."
}

function Convert-ToBranchSlug {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $normalized = $Value.Trim().ToLowerInvariant()
    $normalized = [Regex]::Replace($normalized, "[^a-z0-9]+", "-")
    $normalized = $normalized.Trim("-")

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        throw "TaskName '$Value' does not contain usable branch characters."
    }

    return $normalized
}

$currentBranch = Get-CurrentBranchName
$taskSlug = Convert-ToBranchSlug -Value $TaskName
$branchName = "$BranchPrefix/$taskSlug"
$worktreePath = (Get-Location).Path

if (-not [string]::IsNullOrWhiteSpace($currentBranch)) {
    if ($currentBranch -eq $branchName) {
        Write-Host "Worktree is already on branch '$branchName'."
        exit 0
    }

    throw "Current worktree is already on branch '$currentBranch'. Refusing to switch automatically to '$branchName'."
}

if (Test-LocalBranchExists -BranchName $branchName) {
    throw "Local branch '$branchName' already exists. Choose a new task name or merge/delete the existing branch first."
}

if ($PSCmdlet.ShouldProcess($worktreePath, "Create and switch to branch '$branchName'")) {
    Invoke-Git -Arguments @("switch", "-c", $branchName)
    Write-Host "Created and switched worktree to '$branchName'."
}
