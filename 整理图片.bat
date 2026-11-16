@echo off
title AMOUR blog - fix post images
cd /d "%~dp0"
set "PS_EXE=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS_EXE%" set "PS_EXE=powershell"
echo ============================================
echo   AMOUR blog : move local images into site
echo   (scan _posts, copy images, rewrite paths)
echo ============================================
echo.
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\fix-post-images.ps1"
echo.
echo --- done, press any key to close ---
pause >nul
