$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$source = Join-Path $root 'mod/standalone'
$privateRefs = Join-Path (Split-Path $root -Parent) '_PRIVATE_HEXEN_REFS'
$outputDir = Join-Path $root 'build/standalone'
$output = Join-Path $outputDir 'HEXEN-ARPG-Standalone.ipk3'

$art = @(
    'sprites/weapons/arpg_wp_cleric_sword_idle_a.png',
    'sprites/weapons/arpg_wp_cleric_sword_attack_a.png',
    'sprites/items/arpg_it_chest_common_a.png',
    'sprites/items/arpg_it_ring_common_a.png',
    'effects/arpg_fx_melee_hit_a.png',
    'textures/arpg_tx_wall_a.png',
    'textures/arpg_tx_floor_a.png',
    'textures/arpg_tx_ceiling_a.png'
)
$menuArt = @('title','new_game','options','load','save','quit','episodes','skills','cursor') |
    ForEach-Object { 'ui/menu/arpg_ui_menu_' + $_ + '.png' }
$art += $menuArt
if (@($menuArt | Where-Object { -not (Test-Path -LiteralPath (Join-Path (Join-Path $root 'mod/assets') $_) -PathType Leaf) }).Count) {
    & (Join-Path $PSScriptRoot 'generate-standalone-menu-placeholders.ps1')
}
$animationManifest = Join-Path $root 'docs/standalone/animation-frames.csv'
if (Test-Path -LiteralPath $animationManifest -PathType Leaf) {
    foreach ($frame in @(Import-Csv -LiteralPath $animationManifest)) {
        if ($frame.standalone_file -notmatch '^sprites/(weapons/axe|monsters/ettin)/arpg_[a-z0-9_]+\.png$') {
            throw "Unsafe standalone animation asset path: $($frame.standalone_file)"
        }
        $art += $frame.standalone_file
    }
}
$missingArt = @($art | Where-Object { -not (Test-Path -LiteralPath (Join-Path (Join-Path $root 'mod/assets') $_) -PathType Leaf) })
if ($missingArt.Count) {
    & (Join-Path $PSScriptRoot 'generate-standalone-placeholders.ps1') | Out-Null
}

$files = @(
    @('IWADINFO', (Join-Path $source 'IWADINFO')),
    @('MAPINFO', (Join-Path $source 'MAPINFO')),
    @('TEXTURES', (Join-Path $source 'TEXTURES')),
    @('zscript.txt', (Join-Path $source 'zscript.txt')),
    @('zscript/prototype.zs', (Join-Path $source 'zscript/prototype.zs'))
)
foreach ($relative in $art) {
    $files += ,@(('assets/' + $relative), (Join-Path (Join-Path $root 'mod/assets') $relative))
}
foreach ($pair in $files) {
    if (-not (Test-Path -LiteralPath $pair[1] -PathType Leaf)) { throw "Missing standalone source: $($pair[1])" }
}
$mapWad = Join-Path $source 'maps/MAP01.wad'
if (-not (Test-Path -LiteralPath $mapWad -PathType Leaf)) { throw "Missing standalone map: $mapWad" }
if ((Resolve-Path -LiteralPath $mapWad).Path.StartsWith($privateRefs, [StringComparison]::OrdinalIgnoreCase)) { throw 'Private reference path is forbidden in the standalone build.' }

function Add-Bytes([IO.Compression.ZipArchive] $archive, [string] $name, [byte[]] $bytes) {
    $entry = $archive.CreateEntry($name, [IO.Compression.CompressionLevel]::Optimal)
    $stream = $entry.Open()
    try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
}

function Assert-StandaloneMap([string] $path) {
    $bytes = [IO.File]::ReadAllBytes($path)
    if ($bytes.Length -lt 12 -or [Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'PWAD') { throw 'Standalone map must be a PWAD.' }
    $count = [BitConverter]::ToInt32($bytes, 4)
    $directory = [BitConverter]::ToInt32($bytes, 8)
    if ($count -lt 3 -or $directory -lt 12 -or [long]$directory + [long]$count * 16 -gt $bytes.Length) { throw 'Invalid standalone map directory.' }
    $names = for ($i = 0; $i -lt $count; $i++) { [Text.Encoding]::ASCII.GetString($bytes, $directory + $i * 16 + 8, 8).Trim([char]0) }
    if ($names[0] -ne 'MAP01' -or $names -notcontains 'TEXTMAP' -or $names -notcontains 'ENDMAP') { throw 'MAP01.wad must contain MAP01, TEXTMAP and ENDMAP.' }
    foreach ($name in $names) { if ($name -match '^(PLAYPAL|COLORMAP|S_START|S_END|P_START|P_END|F_START|F_END|ZSCRIPT|TEXTURES)$') { throw "Map WAD contains forbidden resource lump: $name" } }
    return $bytes
}

# A self-made RGB332 palette and identity colormap. No IWAD palette is read.
$palette = [byte[]]::new(768)
for ($i = 0; $i -lt 256; $i++) {
    $palette[3 * $i] = [byte]([int][Math]::Round((($i -shr 5) -band 7) * 255 / 7))
    $palette[3 * $i + 1] = [byte]([int][Math]::Round((($i -shr 2) -band 7) * 255 / 7))
    $palette[3 * $i + 2] = [byte]([int][Math]::Round(($i -band 3) * 255 / 3))
}
$colormap = [byte[]]::new(34 * 256)
for ($level = 0; $level -lt 34; $level++) {
    for ($i = 0; $i -lt 256; $i++) { $colormap[$level * 256 + $i] = [byte]$i }
}

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
$temporary = Join-Path $outputDir ('standalone-' + [Guid]::NewGuid().ToString('N') + '.tmp')
try {
    $archive = [IO.Compression.ZipFile]::Open($temporary, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($pair in $files) {
            if ($pair[0] -eq 'TEXTURES') {
                $baseText = [IO.File]::ReadAllText($pair[1])
                $animationText = [IO.File]::ReadAllText((Join-Path $source 'ANIMATION_TEXTURES'))
                Add-Bytes $archive 'TEXTURES' ([Text.Encoding]::UTF8.GetBytes($baseText + "`n" + $animationText))
            } else {
                Add-Bytes $archive $pair[0] ([IO.File]::ReadAllBytes($pair[1]))
            }
        }
        Add-Bytes $archive 'maps/MAP01.wad' (Assert-StandaloneMap $mapWad)
        Add-Bytes $archive 'PLAYPAL' $palette
        Add-Bytes $archive 'COLORMAP' $colormap
        Add-Bytes $archive 'docs/LICENSE' ([IO.File]::ReadAllBytes((Join-Path $root 'LICENSE')))
        Add-Bytes $archive 'docs/RIGHTS.md' ([IO.File]::ReadAllBytes((Join-Path $root 'RIGHTS.md')))
        Add-Bytes $archive 'docs/ORIGINAL-CONTENT.md' ([IO.File]::ReadAllBytes((Join-Path $root 'LICENSES/ORIGINAL-CONTENT.md')))
    } finally { $archive.Dispose() }
    Copy-Item -LiteralPath $temporary -Destination $output -Force
} finally { Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue }
Write-Output $output
