@echo off
setlocal enabledelayedexpansion
title Campus Store CRM - Backend (9090)

REM ============================================================
REM  Start Spring Boot backend
REM  Workdir MUST be the project root (code2026), because
REM  FileController uses  user.dir + "/files/"  for uploads.
REM ============================================================

if not defined JAVA_HOME (
    if exist "D:\dsh-tools\jdk21\jdk-21.0.12.1+1\bin\java.exe" (
        set "JAVA_HOME=D:\dsh-tools\jdk21\jdk-21.0.12.1+1"
    )
)
if not defined JAVA_HOME (
    echo [ERROR] JAVA_HOME not found. Install JDK 21 and set JAVA_HOME.
    pause
    exit /b 1
)

pushd "%~dp0.."
if not exist "springboot\target\springboot-0.0.1-SNAPSHOT.jar" (
    echo [ERROR] jar not found. Build it first:
    echo         cd springboot ^&^& mvn clean package -DskipTests
    popd
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   Backend : http://localhost:9090
echo   WorkDir : %CD%
echo ============================================================
echo.

REM --spring.main.lazy-initialization=true is required in restricted
REM sandbox/container environments where eager init gets killed.
REM On a normal dev machine it is optional.
"%JAVA_HOME%\bin\java.exe" -Dfile.encoding=UTF-8 ^
    -jar "springboot\target\springboot-0.0.1-SNAPSHOT.jar" ^
    --spring.main.lazy-initialization=true %*

popd
pause
