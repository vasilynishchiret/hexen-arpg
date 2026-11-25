param(
    [Parameter(Mandatory = $true)][string] $IWAD,
    [string] $PrivateRoot,
    [switch] $ForceRegenerate
)
$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $PrivateRoot) { $PrivateRoot = Join-Path (Split-Path $root -Parent) '_PRIVATE_HEXEN_REFS' }
$privateFull = [IO.Path]::GetFullPath($PrivateRoot).TrimEnd('\')
$repoFull = [IO.Path]::GetFullPath($root).TrimEnd('\')
if ($privateFull.Equals($repoFull, [StringComparison]::OrdinalIgnoreCase) -or
    $privateFull.StartsWith($repoFull + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Private Hexen references must be outside the Git repository.'
}
if (-not (Test-Path -LiteralPath $IWAD -PathType Leaf)) { throw "IWAD not found: $IWAD" }
$wadFull = (Resolve-Path -LiteralPath $IWAD).Path
if ([IO.Path]::GetFileName($wadFull) -ine 'HEXEN.WAD') { throw 'Select HEXEN.WAD, not another game IWAD.' }
New-Item -ItemType Directory -Force -Path $privateFull | Out-Null
Add-Type -Path (Join-Path $PSScriptRoot 'standalone-frames.cs') -ReferencedAssemblies @('System.Drawing', 'System.Core')
$csvPath = [StandaloneFrames]::Export($wadFull, $privateFull, (Join-Path $root 'mod/assets'), [bool]$ForceRegenerate)
$rows = @(Import-Csv -LiteralPath $csvPath)
if ($rows.Count -lt 100) { throw "Unexpectedly few frames: $($rows.Count)" }

foreach ($row in $rows) {
    $letter = $row.lump.Substring(4, 1)
    $phase = 'unassigned'; $states = 'not used by selected actor'; $ticks = ''
    if ($row.lump.StartsWith('FAXE')) {
        switch ($letter) {
            'A' { $phase='idle/recovery'; $states='Select,Deselect,Ready,EndAttack,FireGlow recovery'; $ticks='1' }
            'B' { $phase='attack'; $states='Fire'; $ticks='4' }
            'C' { $phase='attack'; $states='Fire'; $ticks='3' }
            'D' { $phase='attack/impact/recovery'; $states='Fire,EndAttack'; $ticks='2|1|2' }
            'E' { $phase='recovery'; $states='EndAttack'; $ticks='1|2|7' }
            'L' { $phase='glow idle'; $states='SelectGlow,DeselectGlow,ReadyGlow'; $ticks='1' }
            'M' { $phase='glow idle'; $states='ReadyGlow'; $ticks='1' }
            'N' { $phase='glow attack'; $states='FireGlow'; $ticks='4' }
            'O' { $phase='glow attack'; $states='FireGlow'; $ticks='3' }
            'P' { $phase='glow attack/impact'; $states='FireGlow'; $ticks='2|1|2' }
            'Q' { $phase='glow recovery'; $states='FireGlow'; $ticks='1|2|7' }
            default { if ($letter -in @('R','S','T','U','V','W','X')) { $phase='glow impact puff'; $states='AxePuffGlow.Spawn'; $ticks='4' } }
        }
    } elseif ($row.lump.StartsWith('ETTN')) {
        switch ($letter) {
            'A' { $phase='idle/walk'; $states='Ettin.Spawn,Ettin.See'; $ticks='10|5' }
            'B' { $phase='walk'; $states='Ettin.See'; $ticks='5' }
            'C' { $phase='walk'; $states='Ettin.See'; $ticks='5' }
            'D' { $phase='walk'; $states='Ettin.See'; $ticks='5' }
            'E' { $phase='melee windup'; $states='Ettin.Melee'; $ticks='6' }
            'F' { $phase='melee windup'; $states='Ettin.Melee'; $ticks='6' }
            'G' { $phase='melee impact'; $states='Ettin.Melee'; $ticks='8' }
            'H' { $phase='pain'; $states='Ettin.Pain'; $ticks='7' }
            'I' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'J' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'K' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'L' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'M' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'N' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'O' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'P' { $phase='death'; $states='Ettin.Death'; $ticks='4' }
            'Q' { $phase='corpse'; $states='Ettin.Death'; $ticks='-1' }
            'R' { $phase='ice death'; $states='Ettin.Ice'; $ticks='5|1' }
        }
    } else {
        if ($letter -in @('A','B','C','D','E','F','G','H','I','J','K')) { $phase='gib death'; $states='Ettin.XDeath'; $ticks='4' }
        if ($letter -eq 'L') { $phase='gib corpse'; $states='Ettin.XDeath'; $ticks='-1' }
        if ($letter -in @('M','N','O','P')) { $phase='dropped mace'; $states='EttinMace.Spawn'; $ticks='5' }
        if ($letter -in @('Q','R')) { $phase='dropped mace crash'; $states='EttinMace.Crash'; $ticks='5' }
        if ($letter -eq 'S') { $phase='dropped mace rest'; $states='EttinMace.Crash'; $ticks='-1' }
    }
    $row | Add-Member -NotePropertyName frame_order -NotePropertyValue ([int][char]$letter - [int][char]'A')
    $row | Add-Member -NotePropertyName directions -NotePropertyValue $(if ($row.lump -match '^[A-Z]{4}[A-H][1-8]$') { '1-8' } else { '0' })
    $row | Add-Member -NotePropertyName phase -NotePropertyValue $phase
    $row | Add-Member -NotePropertyName state_mapping -NotePropertyValue $states
    $row | Add-Member -NotePropertyName tick_durations -NotePropertyValue $ticks
}

# The public manifest contains only technical metadata and relative local paths.
$public = Join-Path $root 'docs/standalone/animation-frames.csv'
$rows | Export-Csv -LiteralPath $public -NoTypeInformation -Encoding UTF8
$mapping = [Collections.Generic.List[string]]::new()
$mapping.Add('// Generated mappings for original placeholder geometry only.')
$mapping.Add('// Never paste Hexen sprite names or image data here.')
foreach ($row in $rows) {
    $runtime = $row.runtime_name
    if ($runtime -notmatch '^(ARXA|ARET|AREB)[A-Z][0-9]$') { throw "Unexpected runtime identifier: $runtime" }
    $mapping.Add("Sprite $runtime, $($row.width), $($row.height)")
    $mapping.Add('{')
    $mapping.Add("    Offset $($row.left_offset), $($row.top_offset)")
    $mapping.Add("    Patch `"assets/$($row.standalone_file)`", 0, 0")
    $mapping.Add('}')
    $mapping.Add('')
}
$mapping.RemoveAt($mapping.Count - 1)
$mappingPath = Join-Path $root 'mod/standalone/ANIMATION_TEXTURES'
[IO.File]::WriteAllLines($mappingPath, $mapping, [Text.UTF8Encoding]::new($false))
Write-Output "Private PNG references: $privateFull"
Write-Output "Public metadata: $public"
Write-Output "Standalone placeholders: $($rows.Count) frames"
Write-Output "Runtime mappings: $mappingPath"
