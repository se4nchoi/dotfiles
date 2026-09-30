# Install or upgrade Claude Code via winget, then copy the binary into the
# persistent workspace so it survives profile resets.
param(
    [string]$WorkspaceRoot = "E:\portable-workspace"
)

$installRoot = Join-Path $WorkspaceRoot "programs\claude\bin"
$packageId = "Anthropic.ClaudeCode"

winget install --id $packageId -e --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -ne 0) {
    winget upgrade --id $packageId -e --accept-source-agreements --accept-package-agreements
}

$source = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\$packageId*\claude.exe" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $source) {
    Write-Error "claude.exe was not found in the winget package directory."
    exit 1
}

New-Item -ItemType Directory -Force $installRoot | Out-Null
Copy-Item $source.FullName (Join-Path $installRoot "claude.exe") -Force
& (Join-Path $installRoot "claude.exe") --version
