@echo off
title Typora - disable GPU (fix typing lag)
set "TY=D:\tools\Typora\Typora.exe"
if not exist "%TY%" (
  echo [ERROR] Typora not found: %TY%
  pause
  exit /b 1
)
echo Starting Typora with --disable-gpu ...
echo (make sure Typora is fully quit first, including the tray icon)
start "" "%TY%" --disable-gpu %*
exit /b 0
