@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launchstandalone.ps1" %*
if errorlevel 1 (
    echo.
    echo HEXEN-ARPG Standalone could not start. See the error above.
    pause
)
