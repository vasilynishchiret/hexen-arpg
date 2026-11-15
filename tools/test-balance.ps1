$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$balance = Get-Content (Join-Path $root 'mod/zscript/systems/balance.zs') -Raw -Encoding UTF8
$rules = Get-Content (Join-Path $root 'mod/zscript/loot/weapon_data.zs') -Raw -Encoding UTF8
$generation = Get-Content (Join-Path $root 'mod/zscript/loot/generation.zs') -Raw -Encoding UTF8
$weapons = Get-Content (Join-Path $root 'mod/zscript/weapons/equipped.zs') -Raw -Encoding UTF8
$regen = Get-Content (Join-Path $root 'mod/zscript/mana/regeneration.zs') -Raw -Encoding UTF8
$cleric = Get-Content (Join-Path $root 'mod/zscript/player/arpg_cleric.zs') -Raw -Encoding UTF8
$textures = Get-Content (Join-Path $root 'mod/TEXTURES') -Raw -Encoding UTF8

function Assert([bool] $condition, [string] $message) {
    if (-not $condition) { throw $message }
}

function Const([string] $name) {
    $match = [regex]::Match($balance, "const\s+$([regex]::Escape($name))\s*=\s*(\d+)\s*;")
    Assert $match.Success "Missing balance constant $name"
    return [int]$match.Groups[1].Value
}

function RefireTics([string] $kind) {
    $match = [regex]::Match($weapons, "(?ms)^\s+$($kind)Fire:\s*(.*?A_ReFire;)")
    Assert $match.Success "No $kind refire state"
    $section = $match.Groups[1].Value
    Assert (([regex]::Matches($section, 'A_ARPGBeginAttack')).Count -eq 1) "$kind does not begin exactly once"
    Assert (([regex]::Matches($section, 'A_ARPGStrike')).Count -eq 1) "$kind does not strike exactly once"
    $ticks = 0
    foreach ($line in ($section -split "`n")) {
        $frame = [regex]::Match($line, '^\s*[A-Z0-9]{4}\s+[A-Z]+\s+(\d+)\b')
        if ($frame.Success) { $ticks += [int]$frame.Groups[1].Value }
    }
    return $ticks
}

Assert ($generation.Contains('random[ARPGLootChance](0, ARPGBalance.LOOT_ONE_IN - 1) == 0')) 'Drop roll diverged from 1/N'
Assert ($rules.Contains('random[ARPGLootBand](0, 99)')) 'Damage tier roll diverged from 100 outcomes'
Assert ($regen.Contains('BT_RUN') -and $regen.Contains('cmd.forwardmove') -and $regen.Contains('cmd.sidemove')) 'Run + movement gate missing'
Assert ($cleric.Contains('override void FireWeapon(State stat)') -and $cleric.Contains('arpgAttackCooldown > 0')) 'Attack cancellation gate missing'
Assert ($cleric.Contains('Health ARPGBalance.BASE_HEALTH;') -and $cleric.Contains('Player.MaxHealth ARPGBalance.BASE_HEALTH;')) 'New-game health is not balanced'
Assert ((Const 'BASE_HEALTH') -eq 50) 'Base health is not 50'
Assert ($textures.Contains('patches/arpg_sword/WBLADEA0.png')) 'Sword world sprite is not WBLADEA0.png'
Assert (Test-Path (Join-Path $root 'mod/patches/arpg_sword/WBLADEA0.png')) 'Sword world PNG missing'

foreach ($kind in @('SWORD', 'AXE', 'HAMMER')) {
    $actual = RefireTics (Get-Culture).TextInfo.ToTitleCase($kind.ToLower())
    $expected = Const "${kind}_ATTACK_TICS"
    Assert ($actual -eq $expected) "$kind cadence: states $actual, balance $expected"
    Write-Output "$kind cadence: $actual tics, $([Math]::Round(35 / $actual, 3)) attacks/s"
}

$oneIn = Const 'LOOT_ONE_IN'
$common = Const 'LOOT_COMMON_PERCENT'
$strong = Const 'LOOT_STRONG_PERCENT'
$exceptional = Const 'LOOT_EXCEPTIONAL_PERCENT'
Assert ($oneIn -eq 15) 'Drop chance is not 1/15'
Assert ($common + $strong + $exceptional -eq 100) 'Damage tiers must total 100%'
$scale = Const 'LOOT_MULTIPLIER_SCALE'
$bands = @(
    @((Const 'LOOT_COMMON_MIN'), (Const 'LOOT_COMMON_MAX')),
    @((Const 'LOOT_STRONG_MIN'), (Const 'LOOT_STRONG_MAX')),
    @((Const 'LOOT_EXCEPTIONAL_MIN'), (Const 'LOOT_EXCEPTIONAL_MAX'))
)
$rng = [Random]::new(20261115)
$kills = 300000
$drops = 0
$counts = @(0, 0, 0)
for ($i = 0; $i -lt $kills; $i++) {
    if ($rng.Next($oneIn) -ne 0) { continue }
    $drops++
    $roll = $rng.Next(100)
    $tier = if ($roll -lt $common) { 0 } elseif ($roll -lt $common + $strong) { 1 } else { 2 }
    $counts[$tier]++
    $multiplier = $rng.Next($bands[$tier][0], $bands[$tier][1] + 1)
    foreach ($base in @((Const 'SWORD_DAMAGE'), (Const 'AXE_DAMAGE'), (Const 'HAMMER_DAMAGE'))) {
        $damage = [int][Math]::Floor(($base * $multiplier + $scale / 2) / $scale)
        Assert ($damage -gt 0) 'Generated damage is not positive'
    }
}
$dropRate = $drops / $kills
Assert ([Math]::Abs($dropRate - 1 / $oneIn) -lt 0.003) "Drop sample outside tolerance: $dropRate"
foreach ($tier in 0..2) {
    $observed = $counts[$tier] / $drops
    $expected = @($common, $strong, $exceptional)[$tier] / 100
    Assert ([Math]::Abs($observed - $expected) -lt 0.012) "Tier $tier outside tolerance: $observed"
}
Write-Output "Simulated $kills kills: $drops drops ($([Math]::Round($dropRate * 100, 2))%)"
Write-Output "Damage tiers: $($counts -join ', ') ($([Math]::Round($counts[0]/$drops*100,2))% / $([Math]::Round($counts[1]/$drops*100,2))% / $([Math]::Round($counts[2]/$drops*100,2))%)"
