$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later

# Staged standalone art. Draws only geometric primitives and literal colours;
# it does not read Hexen, UZDoom, existing PNGs, or any other source image.
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$specs = @(
    @('sprites/weapons/arpg_wp_cleric_sword_idle_a.png', 'sword', '#71D9EC', 128, 96),
    @('sprites/weapons/arpg_wp_cleric_sword_attack_a.png', 'sword_attack', '#71D9EC', 128, 96),
    @('sprites/weapons/arpg_wp_cleric_mace_idle_a.png', 'mace', '#E1BC6A', 128, 96),
    @('sprites/weapons/arpg_wp_cleric_staff_idle_a.png', 'staff', '#72C98D', 128, 96),
    @('sprites/weapons/arpg_wp_cleric_firestorm_idle_a.png', 'firestaff', '#F18A59', 128, 96),
    @('sprites/items/arpg_it_sword_common_a.png', 'sword', '#71D9EC', 48, 48),
    @('sprites/items/arpg_it_chest_common_a.png', 'chest', '#CFA976', 48, 48),
    @('sprites/items/arpg_it_ring_common_a.png', 'ring', '#E1BC6A', 48, 48),
    @('sprites/gems/arpg_gem_blue_a.png', 'gem', '#5DA8F3', 48, 48),
    @('sprites/gems/arpg_gem_green_a.png', 'gem', '#70D38C', 48, 48),
    @('sprites/gems/arpg_gem_combined_a.png', 'combined', '#8DB7DB', 48, 48),
    @('ui/arpg_ui_inventory_bg.png', 'panel', '#37495B', 256, 160),
    @('ui/arpg_ui_slot_empty.png', 'slot', '#728496', 48, 48),
    @('effects/arpg_fx_lightning_hit_a.png', 'lightning', '#78CBF4', 64, 64),
    @('effects/arpg_fx_melee_hit_a.png', 'impact', '#F5CE79', 64, 64)
)

foreach ($spec in $specs) {
    $relative = $spec[0]
    $kind = $spec[1]
    $accent = [System.Drawing.ColorTranslator]::FromHtml($spec[2])
    $width = [int]$spec[3]
    $height = [int]$spec[4]
    $output = Join-Path (Join-Path $root 'mod/assets') $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $output) | Out-Null
    $bitmap = [System.Drawing.Bitmap]::new($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bitmap)
    $border = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 18, 27, 38), 3)
    $light = [System.Drawing.Pen]::new($accent, 5)
    $thin = [System.Drawing.Pen]::new($accent, 2)
    $fill = [System.Drawing.SolidBrush]::new($accent)
    $dark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230, 26, 39, 53))
    try {
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.TranslateTransform([float]($width - 64) / 2, [float]($height - 64) / 2)
        switch ($kind) {
            { $_ -in 'sword', 'sword_attack' } {
                if ($kind -eq 'sword_attack') { $g.RotateTransform(35) }
                $g.DrawLine($border, 15, 53, 48, 9)
                $g.DrawLine($light, 15, 53, 48, 9)
                $g.DrawLine($thin, 8, 42, 27, 54)
                $g.FillEllipse($fill, 9, 51, 7, 7)
            }
            'mace' {
                $g.DrawLine($border, 16, 54, 39, 14)
                $g.DrawLine($light, 16, 54, 39, 14)
                $g.FillEllipse($dark, 30, 5, 23, 23)
                $g.DrawEllipse($light, 30, 5, 23, 23)
            }
            { $_ -in 'staff', 'firestaff' } {
                $g.DrawLine($border, 18, 57, 41, 9)
                $g.DrawLine($light, 18, 57, 41, 9)
                $g.FillEllipse($dark, 34, 3, 16, 16)
                $g.DrawEllipse($thin, 34, 3, 16, 16)
                if ($kind -eq 'firestaff') { $g.DrawLine($thin, 36, 2, 43, -5) }
            }
            'chest' {
                $g.FillRectangle($dark, 8, 17, 48, 36)
                $g.DrawRectangle($light, 8, 17, 48, 36)
                $g.DrawLine($thin, 9, 29, 55, 29)
                $g.FillRectangle($fill, 29, 27, 6, 12)
            }
            'ring' {
                $g.DrawEllipse($border, 13, 20, 38, 34)
                $g.DrawEllipse($light, 13, 20, 38, 34)
                $g.FillEllipse($fill, 25, 8, 14, 14)
            }
            { $_ -in 'gem', 'combined' } {
                $points = [System.Drawing.Point[]]@(
                    [System.Drawing.Point]::new(32, 5), [System.Drawing.Point]::new(53, 25),
                    [System.Drawing.Point]::new(32, 58), [System.Drawing.Point]::new(11, 25))
                $g.FillPolygon($fill, $points)
                $g.DrawPolygon($border, $points)
                $g.DrawLine($thin, 11, 25, 53, 25)
                if ($kind -eq 'combined') { $g.DrawLine($border, 32, 7, 32, 55) }
            }
            'panel' {
                $g.ResetTransform()
                $g.FillRectangle($dark, 3, 3, $width - 6, $height - 6)
                $g.DrawRectangle($light, 3, 3, $width - 6, $height - 6)
                $g.DrawLine($thin, 12, 29, $width - 12, 29)
            }
            'slot' {
                $g.FillRectangle($dark, 8, 8, 48, 48)
                $g.DrawRectangle($light, 8, 8, 48, 48)
            }
            'lightning' {
                $points = [System.Drawing.Point[]]@(
                    [System.Drawing.Point]::new(35, 3), [System.Drawing.Point]::new(17, 32),
                    [System.Drawing.Point]::new(30, 32), [System.Drawing.Point]::new(24, 61),
                    [System.Drawing.Point]::new(50, 26), [System.Drawing.Point]::new(37, 26))
                $g.FillPolygon($fill, $points)
                $g.DrawPolygon($border, $points)
            }
            'impact' {
                for ($i = 0; $i -lt 8; $i++) {
                    $angle = $i * [Math]::PI / 4
                    $x1 = 32 + [int](12 * [Math]::Cos($angle))
                    $y1 = 32 + [int](12 * [Math]::Sin($angle))
                    $x2 = 32 + [int](28 * [Math]::Cos($angle))
                    $y2 = 32 + [int](28 * [Math]::Sin($angle))
                    $g.DrawLine($light, $x1, $y1, $x2, $y2)
                }
                $g.FillEllipse($fill, 25, 25, 14, 14)
            }
        }
        $bitmap.Save($output, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $dark.Dispose(); $fill.Dispose(); $thin.Dispose(); $light.Dispose()
        $border.Dispose(); $g.Dispose(); $bitmap.Dispose()
    }
    Write-Output $relative
}
