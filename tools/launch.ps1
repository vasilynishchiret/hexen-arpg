$ErrorActionPreference = 'Stop'
$UZDoom = 'C:\Games\UZDoom\uzdoom.exe'
$IWAD = 'C:\Games\UZDoom\HEXEN.WAD'
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
    } else {
        $gameArgs += $args[$i]
    }
}

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$mod = Join-Path $projectRoot 'mod'

foreach ($path in @($UZDoom, $IWAD, (Join-Path $mod 'zscript.txt'))) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "File not found: $path"
    }
}

if ($MapWad) {
    if (-not (Test-Path -LiteralPath $MapWad -PathType Leaf)) { throw "Map file not found: $MapWad" }
    $MapWad = (Resolve-Path -LiteralPath $MapWad -ErrorAction Stop).Path
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
