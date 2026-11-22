@echo off
rem Copyright (C) 2026 Vasily Nishchiret
rem SPDX-License-Identifier: GPL-3.0-or-later

setlocal
cd /d "%~dp0"
if not "%~1"=="" (
  set "MAPFILE=%~1"
  goto launch
)
set "MAPCHOICE=%TEMP%\hexen-arpg-map-%RANDOM%.txt"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; $d = New-Object System.Windows.Forms.OpenFileDialog; $d.Title = 'Select a Hexen-compatible map'; $d.Filter = 'Map archives (*.wad;*.pk3;*.pk7)|*.wad;*.pk3;*.pk7'; if ($d.ShowDialog() -eq 'OK') { $d.FileName }" > "%MAPCHOICE%"
for /f "usebackq delims=" %%F in ("%MAPCHOICE%") do set "MAPFILE=%%F"
del /q "%MAPCHOICE%" >nul 2>&1
if not defined MAPFILE (
  echo No map selected.
  exit /b 1
)
:launch
if "%~2"=="" (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch.ps1" -MapWad "%MAPFILE%"
) else (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch.ps1" -MapWad "%MAPFILE%" -StartMap "%~2"
)
set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
  echo.
  echo HEXEN-ARPG could not start. Read the error above.
  pause
)
exit /b %EXITCODE%
