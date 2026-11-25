$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$package = Join-Path $root 'build/standalone/HEXEN-ARPG-Standalone.ipk3'
if (-not (Test-Path -LiteralPath $package -PathType Leaf)) { throw 'Build standalone before running package audit.' }
$frames = @(Import-Csv (Join-Path $root 'docs/standalone/animation-frames.csv'))
if ($frames.Count -ne 117) { throw "Unexpected animation count: $($frames.Count)" }
$expected = @('IWADINFO','MAPINFO','TEXTURES','zscript.txt','zscript/prototype.zs',
    'maps/MAP01.wad','PLAYPAL','COLORMAP','docs/LICENSE','docs/RIGHTS.md','docs/ORIGINAL-CONTENT.md')
$expected += @('sprites/weapons/arpg_wp_cleric_sword_idle_a.png','sprites/weapons/arpg_wp_cleric_sword_attack_a.png',
    'sprites/items/arpg_it_chest_common_a.png','sprites/items/arpg_it_ring_common_a.png',
    'effects/arpg_fx_melee_hit_a.png','textures/arpg_tx_wall_a.png',
    'textures/arpg_tx_floor_a.png','textures/arpg_tx_ceiling_a.png') | ForEach-Object { 'assets/' + $_ }
$expected += @('title','new_game','options','load','save','quit','episodes','skills','cursor') |
    ForEach-Object { 'assets/ui/menu/arpg_ui_menu_' + $_ + '.png' }
$expected += $frames | ForEach-Object { 'assets/' + $_.standalone_file }
$archive = [IO.Compression.ZipFile]::OpenRead($package)
try {
    $actual = @($archive.Entries | ForEach-Object FullName)
    $missing = @($expected | Where-Object { $_ -notin $actual })
    $extra = @($actual | Where-Object { $_ -notin $expected })
    if ($missing.Count -or $extra.Count) { throw "Package mismatch. Missing: $($missing -join ', '); extra: $($extra -join ', ')" }
    if (@($actual | Where-Object { $_ -match '(_PRIVATE|HEXEN\.WAD|DOOM\.WAD|HERETIC\.WAD|\.exe$|^mod/)' }).Count) { throw 'Forbidden resource name in standalone package.' }
    $mapEntry = $archive.GetEntry('maps/MAP01.wad')
    $mapBytes = [byte[]]::new([int]$mapEntry.Length)
    $mapStream = $mapEntry.Open()
    try { $offset = 0; while ($offset -lt $mapBytes.Length) { $read = $mapStream.Read($mapBytes, $offset, $mapBytes.Length - $offset); if ($read -le 0) { throw 'Truncated map archive entry.' }; $offset += $read } } finally { $mapStream.Dispose() }
    $sourceBytes = [IO.File]::ReadAllBytes((Join-Path $root 'mod/standalone/maps/MAP01.wad'))
    $hash = [Security.Cryptography.SHA256]::Create()
    try { if ([BitConverter]::ToString($hash.ComputeHash($mapBytes)) -ne [BitConverter]::ToString($hash.ComputeHash($sourceBytes))) { throw 'IPK3 map differs from editable MAP01.wad.' } }
    finally { $hash.Dispose() }
    $textureStream = $archive.GetEntry('TEXTURES').Open()
    $textureReader = [IO.StreamReader]::new($textureStream)
    try { $textureText = $textureReader.ReadToEnd() }
    finally { $textureReader.Dispose() }
    foreach ($frame in $frames) {
        $path = Join-Path $root ('mod/assets/' + $frame.standalone_file)
        $image = [Drawing.Image]::FromFile($path)
        try { if ($image.Width -ne [int]$frame.width -or $image.Height -ne [int]$frame.height) { throw "Frame dimensions changed: $path" } }
        finally { $image.Dispose() }
        $mapping = 'Sprite\s+' + [regex]::Escape($frame.runtime_name) + '\s*,\s*' + [regex]::Escape($frame.width) + '\s*,\s*' + [regex]::Escape($frame.height) + '\s*\{\s*Offset\s+' + [regex]::Escape($frame.left_offset) + '\s*,\s*' + [regex]::Escape($frame.top_offset) + '\s*Patch\s+"assets/' + [regex]::Escape($frame.standalone_file) + '"'
        if ($textureText -notmatch $mapping) { throw "Missing or mismatched runtime frame mapping: $($frame.runtime_name)" }
    }
} finally { $archive.Dispose() }
$tracked = @(git -C $root ls-files)
if (@($tracked | Where-Object { $_ -match '(_PRIVATE_HEXEN_REFS|HEXEN\.WAD|DOOM\.WAD|HERETIC\.WAD)' }).Count) { throw 'Forbidden original game resource tracked by Git.' }
Write-Output "PASS: $($frames.Count) standalone frames, exact MAP01.wad, explicit package whitelist, no private reference paths."
