@echo off
:: GPD WIN Max2 Touchpad Fix - Auto Elevate
:: This script will automatically request admin privileges

set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%QuickTouchpadFix.ps1"

:: Check if already running as admin
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :RunScript
)

:: Request admin elevation
echo.
echo ================================================
echo GPD WIN Max2 Touchpad Fix
echo ================================================
echo.
echo This script requires administrator privileges.
echo Requesting elevation...
echo.

:: Use PowerShell to re-launch with admin
powershell -Command "Start-Process cmd -ArgumentList '/c cd /d "%SCRIPT_DIR%" && powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%" && pause' -Verb RunAs"

exit /b

:RunScript
echo Already running as admin, executing...
cd /d "%SCRIPT_DIR%"
powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
pause
