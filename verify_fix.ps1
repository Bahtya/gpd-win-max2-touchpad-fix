# GPD WIN Max2 Touchpad Fix Verification Script
# Check if the fixes have been applied successfully

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Touchpad Fix Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# 1. Check USB Selective Suspend
Write-Host "[1] Checking USB Selective Suspend..." -ForegroundColor Yellow
$acValue = powercfg /q 2a737441-1930-4402-8d77-b2bebba308a3 48672f38-7a9a-4bb2-8bf8-3d85be19de4e | Select-String "电.*源.*设置.*直流"
$dcValue = powercfg /q 2a737441-1930-4402-8d77-b2bebba308a3 48672f38-7a9a-4bb2-8bf8-3d85be19de4e | Select-String "电.*源.*设置.*交流"

if ($acValue -match "0" -or $acValue -match "已禁用") {
    Write-Host "    [PASS] AC power: Disabled" -ForegroundColor Green
} else {
    Write-Host "    [FAIL] AC power: Still enabled" -ForegroundColor Red
    Write-Host "           Run FixTouchpad.bat again" -ForegroundColor Yellow
    $allPassed = $false
}

if ($dcValue -match "0" -or $dcValue -match "已禁用") {
    Write-Host "    [PASS] DC power: Disabled" -ForegroundColor Green
} else {
    Write-Host "    [FAIL] DC power: Still enabled" -ForegroundColor Red
    $allPassed = $false
}

# 2. Check Fast Startup
Write-Host "`n[2] Checking Fast Startup..." -ForegroundColor Yellow
try {
    $hiberboot = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -ErrorAction Stop
    if ($hiberboot.HiberbootEnabled -eq 0) {
        Write-Host "    [PASS] Fast startup: Disabled" -ForegroundColor Green
    } else {
        Write-Host "    [WARN] Fast startup: Still enabled" -ForegroundColor Yellow
        Write-Host "           This may cause issues but is not critical" -ForegroundColor Gray
    }
} catch {
    Write-Host "    [INFO] Could not check fast startup status" -ForegroundColor Gray
}

# 3. Check Tablet Input Service
Write-Host "`n[3] Checking Tablet Input Service..." -ForegroundColor Yellow
try {
    $service = Get-Service -Name "TabletInputService" -ErrorAction Stop
    if ($service.Status -eq "Running") {
        Write-Host "    [PASS] Tablet Input Service: Running" -ForegroundColor Green
    } else {
        Write-Host "    [WARN] Tablet Input Service: $($service.Status)" -ForegroundColor Yellow
    }
    if ($service.StartType -eq "Automatic") {
        Write-Host "    [PASS] Startup type: Automatic" -ForegroundColor Green
    } else {
        Write-Host "    [INFO] Startup type: $($service.StartType)" -ForegroundColor Gray
    }
} catch {
    Write-Host "    [INFO] Tablet Input Service not found (may be disabled in Windows)" -ForegroundColor Gray
}

# 4. Check I2C HID Devices
Write-Host "`n[4] Checking I2C HID Devices..." -ForegroundColor Yellow
$i2cDevices = Get-PnpDevice | Where-Object {
    $_.FriendlyName -like "*I2C HID*" -or
    $_.InstanceId -like "*GXTP*"
}

if ($i2cDevices) {
    foreach ($device in $i2cDevices) {
        if ($device.Status -eq "OK") {
            Write-Host "    [PASS] $($device.FriendlyName): OK" -ForegroundColor Green
        } else {
            Write-Host "    [WARN] $($device.FriendlyName): $($device.Status)" -ForegroundColor Yellow
            $allPassed = $false
        }
    }
} else {
    Write-Host "    [FAIL] No I2C HID devices found!" -ForegroundColor Red
    $allPassed = $false
}

# 5. Check scheduled task
Write-Host "`n[5] Checking Scheduled Task..." -ForegroundColor Yellow
$task = Get-ScheduledTask -TaskName "TouchpadFix" -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "    [PASS] TouchpadFix task exists" -ForegroundColor Green
    if ($task.State -eq "Ready") {
        Write-Host "    [PASS] Task is enabled" -ForegroundColor Green
    }
} else {
    Write-Host "    [INFO] TouchpadFix task not created (optional)" -ForegroundColor Gray
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "All critical checks PASSED!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`nRecommendations:"
    Write-Host "  - Restart your computer to apply all changes" -ForegroundColor Cyan
    Write-Host "  - Test the touchpad after restart" -ForegroundColor Cyan
} else {
    Write-Host "Some checks FAILED!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "`nPlease run FixTouchpad.bat as Administrator to apply fixes" -ForegroundColor Yellow
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
