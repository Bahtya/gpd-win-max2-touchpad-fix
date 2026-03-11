#!/bin/bash

# GPD WIN Max 2 (2022/2023) Touchpad Fix for Linux (Bazzite/Fedora/SteamOS)
# Target: Goodix GXTP7385 (I2C PNP0C50)

set -e

UDEV_RULE_FILE="/etc/udev/rules.d/99-gpd-win-max2-touchpad.rules"

echo "Applying GPD WIN Max 2 Touchpad Fix..."

# Create udev rule to disable runtime power management for the touchpad and I2C controller
sudo bash -c "cat <<EOF > $UDEV_RULE_FILE
# GPD WIN Max 2 Touchpad (Goodix GXTP7385)
# Disable runtime power management to prevent click failure/unresponsiveness
ACTION==\"add\", SUBSYSTEM==\"i2c\", ATTR{name}==\"PNP0C50:00\", ATTR{power/control}=\"on\"
ACTION==\"add\", SUBSYSTEM==\"i2c\", KERNELS==\"AMDI0010:00\", ATTR{power/control}=\"on\"
EOF"

echo "Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "Applying immediate fix to current session..."
# Try to set it manually for the current session
for dev in /sys/devices/platform/AMDI0010:00/power/control /sys/devices/platform/AMDI0010:00/i2c-0/i2c-PNP0C50:00/power/control; do
    if [ -f "$dev" ]; then
        echo "on" | sudo tee "$dev" > /dev/null
        echo "Set $dev to 'on'"
    fi
done

echo "Fix applied! The touchpad should now remain responsive."
echo "Note: If the problem persists after a deep sleep, you might need to add 'i2c_hid.polling_mode=1' to your kernel boot parameters."
