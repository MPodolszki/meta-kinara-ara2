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
HW_UTILS_DIR="$ART_DIR/hw_utils/"
FLASH_BINARY="./bins/program_flash"

# Define the log directory and file
LOG_DIR="$ART_DIR/saved_logs"
LOG_FILE="$LOG_DIR/program_flash.log"
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

# Navigate to the hardware utilities directory
cd "$HW_UTILS_DIR" || {
	log_message "Error: Failed to navigate to hw_utils directory: $HW_UTILS_DIR" "$LOG_FILE"
	exit 1
}

# Flash the program
log_message "Starting program flash for non-turbo module on i.MX platform" "$LOG_FILE"
#$FLASH_BINARY -e 0 -f ./boot_img/willow_therm.hex | tee flash_output.log 2>&1 | tee -a "$LOG_FILE"
$FLASH_BINARY -e 0 -f ./boot_img/Commercial/Commercial_131072.hex | tee flash_output.log 2>&1 | tee -a "$LOG_FILE"

# Check logs for success message
if grep -q "PROGRAM FLASH SUCCESS" flash_output.log; then
	log_message "Program flash completed successfully for i.MX platform" "$LOG_FILE"
	echo "Script completed. Logs are saved in $LOG_FILE"
	echo "*********************** Now reboot the host system ******************************"
else
	log_message "Error: Program flash failed for i.MX platform" "$LOG_FILE"
	echo "Program flash failed. Logs are saved in $LOG_FILE"
	rm -f flash_output.log
	exit 1
fi

# Clean up
rm -f flash_output.log
