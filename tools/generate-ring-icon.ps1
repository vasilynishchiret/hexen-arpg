$ErrorActionPreference = 'Stop'
# Copyright (C) 2026 Vasily Nishchiret
# SPDX-License-Identifier: GPL-3.0-or-later

Add-Type -AssemblyName System.Drawing
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$folder = Join-Path $projectRoot 'mod\patches\arpg_ring'
New-Item -ItemType Directory -Force -Path $folder | Out-Null
$output = Join-Path $folder 'ARRGA0.png'
$bitmap = [System.Drawing.Bitmap]::new(32, 32, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
try {
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $shadow = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 72, 40, 13), 6)
    $gold = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 225, 177, 60), 4)
    $shine = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(255, 255, 229, 127), 2)
    $gem = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 54, 161, 232))
    try {
        $graphics.DrawEllipse($shadow, 5, 10, 22, 17)
        $graphics.DrawEllipse($gold, 6, 10, 20, 16)
        $graphics.DrawArc($shine, 7, 11, 18, 14, 190, 145)
        $graphics.FillEllipse($gem, 11, 3, 10, 10)
    } finally { $shadow.Dispose(); $gold.Dispose(); $shine.Dispose(); $gem.Dispose() }
    $bitmap.Save($output, [System.Drawing.Imaging.ImageFormat]::Png)
} finally { $graphics.Dispose(); $bitmap.Dispose() }
Write-Output $output
