@echo off
title AMOUR blog - new diary entry
cd /d "%~dp0"
set "PS_EXE=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS_EXE%" set "PS_EXE=powershell"
echo ============================================
echo   AMOUR blog : new diary entry
echo   (press Enter = today, or type 2026-11-13)
echo ============================================
echo.
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\add-diary.ps1" -Open
echo.
echo --- done, press any key to close ---
pause >nul
