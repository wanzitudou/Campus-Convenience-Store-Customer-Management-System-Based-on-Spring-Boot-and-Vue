@echo off
setlocal
title Campus Store CRM - Recommend Service (8000)

REM ============================================================
REM  Smart recommendation service (FastAPI + implicit ALS)
REM    run\start-recommend.cmd train   -> train model from MySQL
REM    run\start-recommend.cmd         -> start HTTP service
REM ============================================================

pushd "%~dp0..\python_recommend"

if not exist ".venv\Scripts\python.exe" (
    echo [INFO] creating virtualenv ...
    python -m venv .venv
    if errorlevel 1 (
        echo [ERROR] python not found. Install Python 3.10-3.12 first.
        popd
        pause
        exit /b 1
    )
    call ".venv\Scripts\python.exe" -m pip install -r requirements.txt
)

if /I "%~1"=="train" (
    echo [INFO] training model from MySQL ...
    call ".venv\Scripts\python.exe" recommend_implicit.py
    popd
    pause
    exit /b 0
)

echo.
echo ============================================================
echo   Recommend service : http://localhost:8000
echo   Health check      : http://localhost:8000/health
echo ============================================================
echo.

set OPENBLAS_NUM_THREADS=1
call ".venv\Scripts\python.exe" -m uvicorn api_implicit:app --host 127.0.0.1 --port 8000
popd
pause
