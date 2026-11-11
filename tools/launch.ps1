$ErrorActionPreference = 'Stop'
$UZDoom = 'C:\Games\UZDoom\uzdoom.exe'
$IWAD = 'C:\Games\UZDoom\HEXEN.WAD'
$gameArgs = @()

for ($i = 0; $i -lt $args.Count; $i++) {
    if ($args[$i] -in @('-UZDoom', '-IWAD')) {
        if ($i + 1 -ge $args.Count) { throw "Missing value for $($args[$i])" }
        if ($args[$i] -eq '-UZDoom') { $UZDoom = $args[++$i] }
        else { $IWAD = $args[++$i] }
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

& $UZDoom -iwad $IWAD -file $mod @gameArgs
exit $LASTEXITCODE
