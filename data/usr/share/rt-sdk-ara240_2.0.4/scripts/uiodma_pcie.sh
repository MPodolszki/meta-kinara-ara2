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

set -e

# Define the base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Update this path as needed
ART_DIR="/usr/share/rt-sdk-ara240"
UIODMA_DIR="$ART_DIR/driver/"

# Log file definition
LOG_DIR="$ART_DIR/saved_logs"
LOG_FILE="$LOG_DIR/uiodma_logs.txt"
mkdir -p "$LOG_DIR"

# Truncate the log file to replace logs from previous runs
>"$LOG_FILE"

# Function to log a message
log_message() {
	local MESSAGE=$1
	local LOG_FILE=$2
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$LOG_FILE"
}

# Ensure the required directory exists
if [ ! -d "$UIODMA_DIR" ]; then
	log_message "Error: Required directory does not exist: $UIODMA_DIR" "$LOG_FILE"
	exit 1
fi

load_uiodma_module() {
	cd "$UIODMA_DIR" || {
		log_message "Error: Failed to navigate to uiodma directory: $UIODMA_DIR" "$LOG_FILE"
		exit 1
	}
	echo "Inserting uiodma driver from the directory $(pwd)"
	# make clean      # make of the uiodma needs a cross compilation
	# make -j8

	if lsmod | grep -wq "uiodma"; then
		echo "UIODMA is already loaded"
	else
		insmod uiodma.ko
		lsmod | grep uiodma
		echo "UIODMA module inserted"
		sleep 2
	fi

	# Register device ID every run so bind works after reboot/reprobe.
	if [ -w /sys/bus/pci/drivers/uiodma/new_id ]; then
		echo "1e58 0002" >/sys/bus/pci/drivers/uiodma/new_id 2>/dev/null || true
	fi

	echo "UIODMA driver installed successfully"
}

verify_pci_device() {
	PCI_DEVICES=$(lspci | grep "1e58" | awk '{print $1}')
	if [ -z "$PCI_DEVICES" ]; then
		log_message "PCI device with ID 1e58 not found" "$LOG_FILE"
		exit 1
	fi
	for PCI_DEVICE in $PCI_DEVICES; do
		log_message "Found PCI device with ID 1e58 at slot address: $PCI_DEVICES" "$LOG_FILE"
	done
}

check_kernel_driver() {
	for PCI_DEVICE in $PCI_DEVICES; do
		lspci -vvv -s $PCI_DEVICE | tee -a "$LOG_FILE"
		DRIVER_IN_USE=""
		if [ -L "/sys/bus/pci/devices/0000:${PCI_DEVICE}/driver" ]; then
			DRIVER_IN_USE=$(basename "$(readlink -f "/sys/bus/pci/devices/0000:${PCI_DEVICE}/driver")")
		else
			DRIVER_IN_USE=$(lspci -k -s $PCI_DEVICE | awk -F': ' '/Kernel driver in use:/ {print $2}')
		fi
		if [[ "$DRIVER_IN_USE" == "uiodma" ]]; then
			log_message "Success: Kernel driver is corectly assigned to uiodma" "$LOG_FILE"
		else
			log_message "Error: Kernel driver is not assigned to uiodma. Check for the avaialability of uiodma driver at the path $(pwd)" "$LOG_FILE"
			return 1
		fi
	done
	return 0
}

bind_pci_devices() {
	for PCI_DEVICE in $PCI_DEVICES; do
		local BDF="0000:${PCI_DEVICE}"
		if [ -L "/sys/bus/pci/devices/${BDF}/driver" ]; then
			local CURRENT_DRIVER
			CURRENT_DRIVER=$(basename "$(readlink -f "/sys/bus/pci/devices/${BDF}/driver")")
			if [ "$CURRENT_DRIVER" = "uiodma" ]; then
				continue
			fi
			if [ -w "/sys/bus/pci/devices/${BDF}/driver/unbind" ]; then
				echo "$BDF" >"/sys/bus/pci/devices/${BDF}/driver/unbind" || true
			fi
		fi

		if [ -w /sys/bus/pci/drivers/uiodma/bind ]; then
			echo "$BDF" >/sys/bus/pci/drivers/uiodma/bind || true
		fi
	done
}

load_driver() {
	verify_pci_device #verify the pcie module got detected
	load_uiodma_module
	bind_pci_devices
	# verify the uiodma driver enabled succesfully
	check_kernel_driver
}

# Main script logic
load_driver

if [ $? -eq 0 ]; then
	log_message "UIODMA driver installed and PCI device verified successfully for i.MX platform" "$LOG_FILE"
	echo ""Script completed. Logs are saved in "$LOG_FILE"
else
	log_message "An error occurred during UIODMA driver installation or PCI device verification for i.MX platform" "$LOG_FILE"
	echo ""Script completed. Logs are saved in "$LOG_FILE"
	exit 1
fi
