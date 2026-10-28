@echo off
setlocal
title Campus Store CRM - Frontend (5173)

REM ============================================================
REM  Start Vite dev server
REM  --host makes it listen on both IPv4 and IPv6,
REM  so both localhost:5173 and 127.0.0.1:5173 work.
REM ============================================================

pushd "%~dp0..\vue"

if not exist "node_modules" (
    echo [INFO] node_modules not found, running npm install ...
    call npm install
    if errorlevel 1 (
        echo [ERROR] npm install failed.
        popd
        pause
        exit /b 1
    )
)

echo.
echo ============================================================
echo   Frontend : http://localhost:5173
echo   API base : see vue\.env.development  (VITE_BASE_URL)
echo ============================================================
echo.

call npm run dev -- --host
popd
pause
