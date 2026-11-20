$ErrorActionPreference = 'Stop'
$UZDoom = $null
$IWAD = $null
$MapWad = $null
$StartMap = $null
$gameArgs = @()

for ($i = 0; $i -lt $args.Count; $i++) {
    if ($args[$i] -in @('-UZDoom', '-IWAD', '-MapWad', '-StartMap')) {
        if ($i + 1 -ge $args.Count) { throw "Missing value for $($args[$i])" }
        switch ($args[$i]) {
            '-UZDoom' { $UZDoom = $args[++$i] }
            '-IWAD' { $IWAD = $args[++$i] }
            '-MapWad' { $MapWad = $args[++$i] }
            '-StartMap' { $StartMap = $args[++$i] }
        }
    } else { $gameArgs += $args[$i] }
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$mod = Join-Path $projectRoot 'mod'

function Find-FirstFile([string[]] $candidates) {
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    return $null
}

function Select-File([string] $title, [string] $filter) {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Title = $title
        $dialog.Filter = $filter
        $dialog.CheckFileExists = $true
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dialog.FileName }
    } catch {
        Write-Host "Windows file picker unavailable: $($_.Exception.Message)"
        $typed = Read-Host "$title (full path, or Enter to cancel)"
        if ($typed) { return $typed.Trim('"') }
    }
    return $null
}

$programFiles = [Environment]::GetFolderPath('ProgramFiles')
$programFilesX86 = [Environment]::GetFolderPath('ProgramFilesX86')
if (-not $UZDoom) {
    $command = Get-Command uzdoom.exe -ErrorAction SilentlyContinue
    $UZDoom = Find-FirstFile @(
        (Join-Path $projectRoot 'uzdoom.exe'),
        (Join-Path $projectRoot 'UZDoom\uzdoom.exe'),
        (Join-Path $projectRoot '..\UZDoom\uzdoom.exe'),
        $(if ($command) { $command.Source }),
        (Join-Path $programFiles 'UZDoom\uzdoom.exe'),
        (Join-Path $programFilesX86 'UZDoom\uzdoom.exe'),
        'C:\Games\UZDoom\uzdoom.exe'
    )
    if (-not $UZDoom) { $UZDoom = Select-File 'Select uzdoom.exe' 'UZDoom (uzdoom.exe)|uzdoom.exe|Executables (*.exe)|*.exe' }
}
if (-not $UZDoom -or -not (Test-Path -LiteralPath $UZDoom -PathType Leaf)) {
    throw 'UZDoom was not found. Install it, then select uzdoom.exe or pass -UZDoom <path>.'
}
$UZDoom = (Resolve-Path -LiteralPath $UZDoom).Path

if (-not $IWAD) {
    $wadCandidates = @(
        (Join-Path $projectRoot 'HEXEN.WAD'),
        (Join-Path $projectRoot 'iwads\HEXEN.WAD'),
        (Join-Path (Split-Path $UZDoom -Parent) 'HEXEN.WAD'),
        (Join-Path $projectRoot '..\HEXEN.WAD'),
        'C:\Games\UZDoom\HEXEN.WAD'
    )
    foreach ($steamRoot in @((Join-Path $programFilesX86 'Steam\steamapps\common'), (Join-Path $programFiles 'Steam\steamapps\common'))) {
        $wadCandidates += Join-Path $steamRoot 'Hexen\base\HEXEN.WAD'
        $wadCandidates += Join-Path $steamRoot 'Hexen\HEXEN.WAD'
        $wadCandidates += Join-Path $steamRoot 'Hexen: Beyond Heretic\base\HEXEN.WAD'
    }
    foreach ($gogRoot in @((Join-Path $programFilesX86 'GOG Galaxy\Games'), (Join-Path $programFiles 'GOG Galaxy\Games'), 'C:\GOG Games')) {
        $wadCandidates += Join-Path $gogRoot 'Hexen\HEXEN.WAD'
        $wadCandidates += Join-Path $gogRoot 'Hexen Beyond Heretic\HEXEN.WAD'
    }
    $IWAD = Find-FirstFile $wadCandidates
    if (-not $IWAD) { $IWAD = Select-File 'Select your legally owned HEXEN.WAD' 'Hexen IWAD (HEXEN.WAD)|HEXEN.WAD|WAD files (*.wad)|*.wad' }
}
if (-not $IWAD -or -not (Test-Path -LiteralPath $IWAD -PathType Leaf)) {
    throw 'HEXEN.WAD was not found. Select your legal copy or pass -IWAD <path>.'
}
$IWAD = (Resolve-Path -LiteralPath $IWAD).Path

if (-not (Test-Path -LiteralPath (Join-Path $mod 'zscript.txt') -PathType Leaf)) {
    throw 'The mod folder is incomplete: mod/zscript.txt is missing.'
}
if ($MapWad) {
    if (-not (Test-Path -LiteralPath $MapWad -PathType Leaf)) { throw "Map file not found: $MapWad" }
    $MapWad = (Resolve-Path -LiteralPath $MapWad).Path
    if ([IO.Path]::GetExtension($MapWad).ToLowerInvariant() -notin @('.wad', '.pk3', '.pk7')) {
        throw 'Map file must be a .wad, .pk3, or .pk7 archive'
    }
}
if ($StartMap -and $StartMap -notmatch '^[A-Za-z][A-Za-z0-9_]{0,7}$') {
    throw 'StartMap must be a map lump name of 1-8 letters, digits, or underscores'
}

$resourceArgs = @()
if ($MapWad) { $resourceArgs += $MapWad }
$resourceArgs += $mod
$startArgs = @()
if ($StartMap) { $startArgs += @('+map', $StartMap) }
$controls = (Join-Path $PSScriptRoot 'controls.cfg').Replace('\', '/')
if ($gameArgs -contains '-config') {
    & $UZDoom -iwad $IWAD -file @resourceArgs '+exec' $controls @gameArgs @startArgs
} else {
    $profileDir = Join-Path $env:LOCALAPPDATA 'HEXEN-ARPG'
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    $profileConfig = Join-Path $profileDir 'uzdoom.ini'
    & $UZDoom -config $profileConfig -iwad $IWAD -file @resourceArgs '+exec' $controls @gameArgs @startArgs
}
exit $LASTEXITCODE
