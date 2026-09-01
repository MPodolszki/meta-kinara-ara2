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
UPTIME=$(cut -d. -f1 /proc/uptime)
WAIT_TIME=90

# Skip if service is bootstrapping
if [[ -f /run/ara240/bootstrap ]]; then
	echo "[ REMOVE ] $UPTIME: Service is bootstrapping. Skipping restart." >>/var/log/udev_ara2_rules.log
	exit 0
fi

# Count USB devices with vendor ID 318d
usb_count=$(grep -l "318d" /sys/bus/usb/devices/*/idVendor 2>/dev/null | wc -l)

# Count PCIe devices with vendor ID 1e58
pcie_count=$(grep -l "0x1e58" /sys/bus/pci/devices/*/vendor 2>/dev/null | wc -l)

total=$((usb_count + pcie_count))

# Read previous count
if [[ -f "$COUNT_FILE" ]]; then
	last_count=$(cat "$COUNT_FILE")
else
	echo "[ REMOVE ] $UPTIME: Reference count not found. Please be sure file ${COUNT_FILE} exist" >>/var/log/udev_ara2_rules.log
	exit 0
fi

# If count changed, restart the service
if [[ "$total" -ne "$last_count" ]]; then
	echo "[ REMOVE ] $UPTIME: Changes on device count updating. curr: $total, prev: $last_count." >>/var/log/udev_ara2_rules.log
	echo "$total" >"$COUNT_FILE"
else
	echo "[ REMOVE ] $UPTIME: Device count still the same..." >>/var/log/udev_ara2_rules.log
fi
