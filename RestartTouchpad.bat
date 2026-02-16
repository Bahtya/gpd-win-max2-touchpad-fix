@echo off
:: Quick Touchpad Restart - Use when click stops working
:: Double-click this file when touchpad becomes unresponsive

setlocal enabledelayedexpansion

echo ================================================
echo Quick Touchpad Restart
echo ================================================
echo.
echo Restarting I2C HID devices...
echo.

:: Use PowerShell to restart I2C HID devices
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-PnpDevice | Where-Object {$_.FriendlyName -like '*I2C HID*' -or $_.InstanceId -like '*GXTP*'} | Select-Object -ExpandProperty InstanceId"') do (
    echo Disabling: %%a
    powershell -NoProfile -Command "Disable-PnpDevice -InstanceId '%%a' -Confirm:$false" 2>nul
    timeout /t 1 /nobreak >nul
    echo Enabling: %%a
    powershell -NoProfile -Command "Enable-PnpDevice -InstanceId '%%a' -Confirm:$false" 2>nul
    timeout /t 1 /nobreak >nul
)

echo.
echo ================================================
echo Touchpad restart complete!
echo ================================================
echo.
echo If click still doesn't work, try:
echo 1. Press Fn + Esc (toggle touchpad)
echo 2. Restart your computer
echo 3. Run QuickFix.bat as administrator
echo.

timeout /t 5
