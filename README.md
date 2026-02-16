# GPD WIN Max2 Touchpad Fix

> Fix touchpad click issues on GPD WIN Max2 (Goodix GXTP7385) running Windows 11

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/platform-Windows-0078D7.svg)]()

## Problem

Touchpad cursor movement works, but clicks occasionally fail. This typically occurs:
- After sleep/wake
- After extended use
- Randomly during operation

## Root Cause

The **Goodix GXTP7385** touchpad connects via I2C. Windows' USB Selective Suspend feature powers down the I2C controller to save energy, causing the touchpad click to stop responding.

## Quick Fix

### Option 1: Automated Script (Recommended)

1. Right-click `FixTouchpad.bat`
2. Select **"Run as administrator"**
3. Click "Yes" on UAC prompt
4. Follow prompts (recommend selecting Y for all options)
5. **Restart your computer**

### Option 2: Manual (No Scripts)

#### Disable USB Selective Suspend

1. Right-click Start → **"Power Options"**
2. Click **"Change plan settings"** next to your current plan
3. Click **"Change advanced power settings"**
4. Expand **"USB settings"** → **"USB selective suspend settings"**
5. Set both **"On battery"** and **"Plugged in"** to **"Disabled"**
6. Click **"Apply"** → **"OK"**

#### Disable Fast Startup

1. Control Panel → **"Power Options"**
2. Click **"Choose what the power buttons do"**
3. Click **"Change settings that are currently unavailable"**
4. Uncheck **"Turn on fast startup"**
5. Click **"Save changes"**

### Option 3: Command Line

Run as Administrator in CMD:

```cmd
:: Disable USB Selective Suspend
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48672f38-7a9a-4bb2-8bf8-3d85be19de4e 0
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48672f38-7a9a-4bb2-8bf8-3d85be19de4e 0
powercfg /SetActive SCHEME_CURRENT

:: Disable Fast Startup
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f

:: Start Tablet Input Service
sc config TabletInputService start= auto
sc start TabletInputService
```

## Temporary Fix When Touchpad Fails

If touchpad stops working without restarting computer:

### Method 1: Quick Restart Script
- Double-click `RestartTouchpad.bat`

### Method 2: Device Manager
1. **Win+X** → **"Device Manager"**
2. Expand **"Human Interface Devices (HID)"**
3. Find **"I2C HID Device"**
4. Right-click → **"Disable device"**
5. Wait 1 second
6. Right-click → **"Enable device"**

### Method 3: Keyboard Shortcut
- Try pressing **Fn + Esc** to toggle touchpad

## Files

| File | Description |
|------|-------------|
| `FixTouchpad.bat` | Main fix tool (run as admin) |
| `RestartTouchpad.bat` | Quick restart when touchpad fails |
| `verify_fix.ps1` | Verify if fixes were applied successfully |

## Technical Details

- **Device**: GPD WIN Max2
- **Touchpad**: Goodix GXTP7385
- **Connection**: I2C (via AMD I2C Controller)
- **Device ID**: `ACPI\GXTP7385\3&C8C3232&0`

The fix disables USB Selective Suspend (GUID: `2a737441-1930-4402-8d77-b2bebba308a3` / `48672f38-7a9a-4bb2-8bf8-3d85be19de4e`), which prevents Windows from powering down the I2C controller.

## If Problem Persists

1. **Update drivers** from GPD official website
2. **Update BIOS/UEFI** firmware
3. **Reinstall drivers** via Device Manager:
   - Find touchpad device → Right-click → **"Uninstall device"**
   - Restart computer (Windows will reinstall)

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Note**: This fix may slightly increase power consumption by disabling USB power saving. The impact on battery life is minimal.
