$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$source = Join-Path $root 'mod/standalone'
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
$mapText = Join-Path $source 'maps/MAP01/TEXTMAP'
if (-not (Test-Path -LiteralPath $mapText -PathType Leaf)) { throw "Missing standalone map: $mapText" }

function Add-Bytes([IO.Compression.ZipArchive] $archive, [string] $name, [byte[]] $bytes) {
    $entry = $archive.CreateEntry($name, [IO.Compression.CompressionLevel]::Optimal)
    $stream = $entry.Open()
    try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
}

function New-MapWad([byte[]] $text) {
    $memory = [IO.MemoryStream]::new()
    $writer = [IO.BinaryWriter]::new($memory)
    try {
        $writer.Write([Text.Encoding]::ASCII.GetBytes('PWAD'))
        $writer.Write([int]3)
        $writer.Write([int]0)
        $entries = @()
        foreach ($lump in @(@('MAP01', [byte[]]@()), @('TEXTMAP', $text), @('ENDMAP', [byte[]]@()))) {
            $position = [int]$memory.Position
            $data = [byte[]]$lump[1]
            $writer.Write($data)
            $entries += ,@($lump[0], $position, $data.Length)
        }
        $directory = [int]$memory.Position
        foreach ($entry in $entries) {
            $writer.Write([int]$entry[1])
            $writer.Write([int]$entry[2])
            $name = [byte[]]::new(8)
            [Text.Encoding]::ASCII.GetBytes([string]$entry[0]).CopyTo($name, 0)
            $writer.Write($name)
        }
        $memory.Position = 8
        $writer.Write($directory)
        return $memory.ToArray()
    } finally { $writer.Dispose(); $memory.Dispose() }
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
            Add-Bytes $archive $pair[0] ([IO.File]::ReadAllBytes($pair[1]))
        }
        Add-Bytes $archive 'maps/MAP01.wad' (New-MapWad ([IO.File]::ReadAllBytes($mapText)))
        Add-Bytes $archive 'PLAYPAL' $palette
        Add-Bytes $archive 'COLORMAP' $colormap
        Add-Bytes $archive 'docs/LICENSE' ([IO.File]::ReadAllBytes((Join-Path $root 'LICENSE')))
        Add-Bytes $archive 'docs/RIGHTS.md' ([IO.File]::ReadAllBytes((Join-Path $root 'RIGHTS.md')))
        Add-Bytes $archive 'docs/ORIGINAL-CONTENT.md' ([IO.File]::ReadAllBytes((Join-Path $root 'LICENSES/ORIGINAL-CONTENT.md')))
    } finally { $archive.Dispose() }
    Copy-Item -LiteralPath $temporary -Destination $output -Force
} finally { Remove-Item -LiteralPath $temporary -Force -ErrorAction SilentlyContinue }
Write-Output $output
