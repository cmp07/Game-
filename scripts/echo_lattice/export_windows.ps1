# Export Echo Lattice for Windows (x86_64 .exe + .pck).
# Usage (from repo root):
#   .\scripts\echo_lattice\export_windows.ps1
# Optional:
#   $env:GODOT_BIN = "C:\Path\To\Godot.exe"
#   .\scripts\echo_lattice\export_windows.ps1 -Preset "Windows Desktop"

[CmdletBinding()]
param(
    [string]$Preset = $(if ($env:PRESET) { $env:PRESET } else { "Windows Desktop" })
)

$ErrorActionPreference = "Stop"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Project = Join-Path $Root "game\echo_lattice"
$OutDir = Join-Path $Root "dist\echo_lattice\windows"
$OutExe = Join-Path $OutDir "EchoLattice.exe"
$ProjectFile = Join-Path $Project "project.godot"

function Resolve-Godot {
    if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) {
        return $env:GODOT_BIN
    }
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd4 = Get-Command godot4 -ErrorAction SilentlyContinue
    if ($cmd4) { return $cmd4.Source }
    return $null
}

if (-not (Test-Path $ProjectFile)) {
    Write-Error @"
missing $ProjectFile
The Godot scaffold must exist before export (see game/echo_lattice on the scaffold branch).
"@
}

$Godot = Resolve-Godot
if (-not $Godot) {
    Write-Error @"
Godot 4.3+ binary not found.
Install Godot and add it to PATH as 'godot' / 'godot4', or set GODOT_BIN.
"@
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Write-Host "==> Godot:  $Godot"
Write-Host "==> Project:$Project"
Write-Host "==> Preset: $Preset"
Write-Host "==> Output: $OutExe"

& $Godot --headless --path $Project --export-release $Preset $OutExe
if ($LASTEXITCODE -ne 0) {
    Write-Error "Godot export failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path $OutExe)) {
    Write-Error "export finished but $OutExe was not created"
}

$Pck = Join-Path $OutDir "EchoLattice.pck"
if (-not (Test-Path $Pck)) {
    Write-Warning "$Pck not found (PCK may be embedded). Check export preset 'Embed PCK'."
}

Write-Host "==> Export OK"
Get-ChildItem $OutDir | Format-Table Name, Length -AutoSize
