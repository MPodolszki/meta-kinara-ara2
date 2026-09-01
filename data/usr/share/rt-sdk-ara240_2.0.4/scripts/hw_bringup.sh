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

DEVICE_ID=$1

# Define the base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Update this path as needed
ART_DIR="/usr/share/rt-sdk-ara240"
HW_UTILS_DIR="$ART_DIR/hw_utils/"

# Define the log directory and file
LOG_DIR="$ART_DIR/saved_logs"
LOG_FILE="$LOG_DIR/hardware_bringup.log"
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
if [ ! -d "$HW_UTILS_DIR" ]; then
	log_message "Error: Required directory does not exist: $HW_UTILS_DIR" "$LOG_FILE"
	exit 1
fi

handle_bringup() {
	cd "$HW_UTILS_DIR" || {
		log_message "Error: Failed to navigate to hw_utils directory: $HW_UTILS_DIR" "$LOG_FILE"
		exit 1
	}
	# Command to get Chip_info
	./bins/chip_info -e "d:${DEVICE_ID}" 2>&1 | tee -a "$LOG_FILE"
	log_message "chip_info before DDR_bringup executed successfully" "$LOG_FILE"
	sleep 2

	# Command to active enable
	./bins/active_enable -e "d:${DEVICE_ID}" -m 2 2>&1 | tee -a "$LOG_FILE"
	if grep -q "TEST PASSED" "$LOG_FILE"; then
		log_message "The Ara2 is pushed to Active state successfully" "$LOG_FILE"
	elif grep -q "TEST FAILED" "$LOG_FILE"; then
		log_message "Failed to push Ara2 to Active state" "$LOG_FILE"
		exit 1
	else
		log_message "⚠️ TEST result not found in logs"
	fi
	sleep 1

	# Commands to bring up DDR
	# PHYTEC: ddr_unified_config / ddr_cfg_*.bin were replaced by the
	# ddr_bringup_sf_600_1200_new_load_ctrl bundle (kinara-ddr-bringup).
	# DDR PLL level: 2 = 900 MHz (default), 3 = 1066 MHz.
	DDR_BRINGUP_DIR="${DDR_BRINGUP_DIR:-/usr/share/rt-sdk-ara240_2.0.4/hw_utils/ddr_bringup}"
	DDR_PLL="${KINARA_DDR_PLL:-2}"
	DDR_CFG_ID="${KINARA_DDR_CFG_ID:-35}"
	( cd "${DDR_BRINGUP_DIR}" && ./ddr_bringup_sf_600_1200_new_load_ctrl_arm64 \
		-i pcie -s 1 -g 1 -l "${DDR_PLL}" -b pytech -m 0 -r 0 -c "${DDR_CFG_ID}" ) \
		2>&1 | tee -a ddr_config_output.txt "$LOG_FILE"
	sleep 2
	# Check DDR configuration result
	if grep -q "DDR BIST: PASSED" ddr_config_output.txt; then
		log_message "DDR configured (PLL level ${DDR_PLL}) in Normal mode" "$LOG_FILE"
	else
		log_message "DDR configuration failed" "$LOG_FILE"
		log_message "Full DDR config logs:" "$LOG_FILE"
		cat ddr_config_output.txt >>"$LOG_FILE" # Append full DDR logs for debugging
		rm ddr_config_output.txt
		log_message "An error occurred during hardware bring-up" "$LOG_FILE"
		exit 1
	fi

	# Clean up
	rm ddr_config_output.txt

	log_message "DDR_bringup to required DDR frequency executed successfully" "$LOG_FILE"
	sleep 2

	# Command to get Chip_info
	./bins/chip_info -e "d:${DEVICE_ID}" 2>&1 | tee -a "$LOG_FILE"
	log_message "chip_info after DDR_bringup executed successfully" "$LOG_FILE"
}

# Main script logic
handle_bringup

if [ $? -eq 0 ]; then
	log_message "Hardware bring-up completed successfully for i.MX Platform" "$LOG_FILE"
	echo ""Script completed. Logs are saved in "$LOG_FILE"
else
	log_message "An error occurred during Hardware bring-up" "$LOG_FILE"
	echo ""Script completed. Logs are saved in "$LOG_FILE"
	exit 1
fi
