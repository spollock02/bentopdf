@echo off
setlocal
cd /d "%~dp0"

:: Ensure node/npm are on PATH
set "PATH=C:\Program Files\nodejs;%PATH%"

echo ===================================================
echo Starting BentoPDF (Production)
echo ===================================================

:: config
set "LOG_DIR=logs"
set "LOG_FILE=%LOG_DIR%\production.log"

:: Create logs directory if it doesn't exist
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo.
echo Phase 0: Killing any existing processes on port 5500...
echo.

:: Method 1: Use netstat to find and kill the process on port 5500
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":5500" ^| findstr "LISTENING"') do (
    echo Found process %%a on port 5500, killing it...
    taskkill /F /PID %%a 2>nul
)

:: Give the system a moment to release the port
timeout /t 2 /nobreak >nul

:: Verify port is clear
netstat -aon | findstr ":5500" | findstr "LISTENING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo WARNING: Port 5500 may still be in use. Waiting 3 more seconds...
    timeout /t 3 /nobreak >nul
)

echo.
echo Logging to %LOG_FILE%
echo Server is starting on port 5500...
echo.

:: Build and serve via vite preview
call npm run build >> "%LOG_FILE%" 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed.
    echo Check %LOG_FILE% for details.
    pause
    exit /b %ERRORLEVEL%
)

call npx vite preview --port 5500 >> "%LOG_FILE%" 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Server crashed or failed to start.
    echo Check %LOG_FILE% for details.
    pause
    exit /b %ERRORLEVEL%
)

endlocal
