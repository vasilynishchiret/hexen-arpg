@echo off
rem Copyright (C) 2026 Vasily Nishchiret
rem SPDX-License-Identifier: GPL-3.0-or-later

setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\launch.ps1" %*
set "EXITCODE=%ERRORLEVEL%"
if not "%EXITCODE%"=="0" (
  echo.
  echo HEXEN-ARPG could not start. Read the error above.
  pause
)
exit /b %EXITCODE%
