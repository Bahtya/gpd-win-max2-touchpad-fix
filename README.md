# GPD WIN Max2 Touchpad Fix

> Fix touchpad click issues on GPD WIN Max2 (Goodix GXTP7385) running Windows 11 or Linux (Bazzite/Fedora)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux-lightgrey.svg)]()

## Problem

Touchpad cursor movement works, but clicks occasionally fail. This typically occurs:
- After sleep/wake
- After extended use
- Randomly during operation

## Root Cause

The **Goodix GXTP7385** touchpad connects via I2C. Windows/Linux power management features power down the I2C controller to save energy, causing the touchpad click to stop responding or communication to drop.

## Windows Quick Fix

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

---

## Linux Fix (Bazzite / Fedora / SteamOS)

The root cause on Linux is the kernel's **Runtime Power Management** putting the I2C controller into a low-power state.

### Quick Fix (Automated)

1. Open a terminal.
2. Navigate to the `linux` folder.
3. Run the following command:
   ```bash
   chmod +x linux/fix_touchpad.sh
   ./linux/fix_touchpad.sh
   ```
4. Enter your sudo password when prompted.

### Manual Fix (udev rule)

Create a file at `/etc/udev/rules.d/99-gpd-win-max2-touchpad.rules` with the following content:

```udev
# GPD WIN Max 2 Touchpad (Goodix GXTP7385)
# Disable runtime power management to prevent click failure/unresponsiveness
ACTION=="add", SUBSYSTEM=="i2c", ATTR{name}=="PNP0C50:00", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="i2c", KERNELS=="AMDI0010:00", ATTR{power/control}="on"
```

Then reload udev rules:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## Technical Details

- **Device**: GPD WIN Max2
- **Touchpad**: Goodix GXTP7385
- **Connection**: I2C (via AMD I2C Controller)
- **Windows Device ID**: `ACPI\GXTP7385\3&C8C3232&0`
- **Linux Device ID**: `PNP0C50:00` (I2C)

The fix disables Runtime Power Management (Windows) or Runtime PM (Linux), which prevents the OS from powering down the I2C controller (`AMDI0010:00`).

## License

MIT License - see [LICENSE](LICENSE) for details.
