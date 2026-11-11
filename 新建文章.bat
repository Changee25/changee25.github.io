@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo   New blog post  /  <xin jian wen zhang>
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\new-post.ps1"
echo.
pause
