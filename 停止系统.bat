@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "run\stop-all.ps1" %*
echo.
pause
