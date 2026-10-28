@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "run\start-all.ps1" %*
echo.
pause
