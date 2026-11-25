$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later

$UZDoom = $null
$noBuild = $false
$gameArgs = @()
for ($i = 0; $i -lt $args.Count; $i++) {
    if ($args[$i] -eq '-UZDoom') {
        if ($i + 1 -ge $args.Count) { throw 'Missing value for -UZDoom' }
        $UZDoom = $args[++$i]
    } elseif ($args[$i] -eq '-NoBuild') {
        $noBuild = $true
    } else {
        $gameArgs += $args[$i]
    }
}

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$package = Join-Path $root 'build/standalone/HEXEN-ARPG-Standalone.ipk3'
if (-not $noBuild -or -not (Test-Path -LiteralPath $package -PathType Leaf)) {
    & (Join-Path $PSScriptRoot 'build-standalone.ps1') | Out-Null
}
if (-not (Test-Path -LiteralPath $package -PathType Leaf)) { throw "Standalone package was not built: $package" }

if (-not $UZDoom) {
    $programFiles = [Environment]::GetFolderPath('ProgramFiles')
    $programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
    $command = Get-Command uzdoom.exe -ErrorAction SilentlyContinue
    $candidates = @(
        (Join-Path $root 'UZDoom/uzdoom.exe'),
        (Join-Path $root '../UZDoom/uzdoom.exe'),
        $(if ($command) { $command.Source }),
        (Join-Path $programFiles 'UZDoom/uzdoom.exe'),
        (Join-Path $programFilesX86 'UZDoom/uzdoom.exe'),
        'C:\Games\UZDoom\uzdoom.exe'
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            $UZDoom = (Resolve-Path -LiteralPath $candidate).Path
            break
        }
    }
    if (-not $UZDoom) {
        try {
            Add-Type -AssemblyName System.Windows.Forms
            $dialog = [System.Windows.Forms.OpenFileDialog]::new()
            $dialog.Title = 'Select uzdoom.exe for HEXEN-ARPG Standalone'
            $dialog.Filter = 'UZDoom (uzdoom.exe)|uzdoom.exe|Executables (*.exe)|*.exe'
            $dialog.CheckFileExists = $true
            if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $UZDoom = $dialog.FileName }
        } catch {
            $UZDoom = Read-Host 'Enter the full path to uzdoom.exe (or Enter to cancel)'
        }
    }
}
if (-not $UZDoom -or -not (Test-Path -LiteralPath $UZDoom -PathType Leaf)) {
    throw 'UZDoom was not found. Install UZDoom 5.0.3, select uzdoom.exe, or pass -UZDoom <path>.'
}
$UZDoom = (Resolve-Path -LiteralPath $UZDoom).Path

$profile = Join-Path $env:LOCALAPPDATA 'HEXEN-ARPG-Standalone'
$saves = Join-Path $profile 'saves'
New-Item -ItemType Directory -Force -Path $saves | Out-Null
$config = Join-Path $profile 'uzdoom.ini'
& $UZDoom -config $config -savedir $saves -noautoload -iwad $package '+map' MAP01 @gameArgs
exit $LASTEXITCODE
