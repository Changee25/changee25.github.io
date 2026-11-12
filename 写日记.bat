@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo   New diary entry  /  <xie ri ji>
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\add-diary.ps1" -Open
echo.
pause
