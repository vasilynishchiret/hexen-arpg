param([switch] $ForceRegenerate)
$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later
Add-Type -AssemblyName System.Drawing
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$folder = Join-Path $root 'mod/assets/ui/menu'
New-Item -ItemType Directory -Force -Path $folder | Out-Null
$labels = [ordered]@{
    title = 'STANDALONE'
    new_game = 'NEW GAME'
    options = 'OPTIONS'
    load = 'LOAD GAME'
    save = 'SAVE GAME'
    quit = 'QUIT GAME'
    episodes = 'EPISODES'
    skills = 'DIFFICULTY'
}
foreach ($item in $labels.GetEnumerator()) {
    $path = Join-Path $folder ('arpg_ui_menu_' + $item.Key + '.png')
    if ((Test-Path -LiteralPath $path) -and -not $ForceRegenerate) { continue }
    $width = if ($item.Key -eq 'title') { 256 } else { 160 }
    $image = [Drawing.Bitmap]::new($width, 36)
    $g = [Drawing.Graphics]::FromImage($image)
    $brush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(255, 90, 221, 185))
    $font = [Drawing.Font]::new('Segoe UI', 16, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
    try {
        $g.Clear([Drawing.Color]::Transparent)
        $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $g.DrawString([string]$item.Value, $font, $brush, [single]4, [single]5)
        $image.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    } finally { $font.Dispose(); $brush.Dispose(); $g.Dispose(); $image.Dispose() }
}
$cursor = Join-Path $folder 'arpg_ui_menu_cursor.png'
if (-not (Test-Path -LiteralPath $cursor) -or $ForceRegenerate) {
    $image = [Drawing.Bitmap]::new(24, 24)
    $g = [Drawing.Graphics]::FromImage($image)
    $brush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(255, 245, 170, 60))
    try {
        $g.Clear([Drawing.Color]::Transparent)
        $g.FillPolygon($brush, [Drawing.Point[]]@([Drawing.Point]::new(2,2),[Drawing.Point]::new(22,12),[Drawing.Point]::new(2,22)))
        $image.Save($cursor, [Drawing.Imaging.ImageFormat]::Png)
    } finally { $brush.Dispose(); $g.Dispose(); $image.Dispose() }
}
