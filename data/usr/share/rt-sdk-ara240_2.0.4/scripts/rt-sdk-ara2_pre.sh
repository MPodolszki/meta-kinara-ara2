#!/usr/bin/env bash

# Copyright (c) 2020-2025 Kinara Inc.
# Copyright 2025-2026 NXP
#
# NXP Proprietary. This software is owned or controlled by NXP and may only be
# used strictly in accordance with the applicable license terms. By expressly
# accepting such terms or by downloading, installing, activating and/or
# otherwise using the software, you are agreeing that you have read, and that
# you agree to comply with and are bound by, such license terms. If you do not
# agree to be bound by the applicable license terms, then you may not retain,
# install, activate or otherwise use the software.

COUNT_FILE="/run/ara240/state"

mkdir -p /run/ara240

echo "Bootstrap start @ $(cut -d. -f1 /proc/uptime)s" >>/var/log/udev_ara2_rules.log

touch /run/ara240/bootstrap

# Count PCIe devices with vendor ID 1e58
pcie_count=$(grep -l "0x1e58" /sys/bus/pci/devices/*/vendor 2>/dev/null | wc -l)

total=$pcie_count

# Exit if no devices found
if [[ "$total" -eq 0 ]]; then
	echo "No matching devices found"
	exit 1
fi

# Save current count
echo "Writting DEVICE_COUNT=$total to: [$COUNT_FILE, /run/ara240/env]"
echo "$total" >"$COUNT_FILE"

# Export the count for the main script
echo "TOTAL_ARA2_DEVICES=$total" > /run/ara240/env
echo "PCIE_DEVICES=$pcie_count" >> /run/ara240/env
exit 0
