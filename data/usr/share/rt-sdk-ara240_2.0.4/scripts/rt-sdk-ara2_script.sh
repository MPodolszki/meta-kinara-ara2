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

# Check for administrative privileges
if [ "$(id -u)" != "0" ]; then
	echo "This script requires administrative privileges."
	echo "Please run this script as root or use sudo."
	exit 1
fi

echo "Running with administrative privileges"

# Define the base and log directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Absolute Path to the scripts directory
ART_DIR="/usr/share/rt-sdk-ara240"

LOG_DIR="$ART_DIR/saved_logs"
LOG_FILE="$LOG_DIR/rt-sdk-ara2_logs.txt"
mkdir -p "$LOG_DIR"

# Truncate existing log
>"$LOG_FILE"

# Log function
log_message() {
	local MESSAGE=$1
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$LOG_FILE"
}

run_script() {
	local SCRIPT=$1

	shift

	if [ -x "$SCRIPT" ]; then
		log_message "Running $SCRIPT ......"
		"$SCRIPT" $@ 2>&1 | tee -a "$LOG_FILE"
		local EXIT_CODE=${PIPESTATUS[0]}
		if [ $EXIT_CODE -ne 0 ]; then
			log_message "$SCRIPT failed with exit code $EXIT_CODE."
			exit $EXIT_CODE
		fi
		log_message "$SCRIPT completed successfully."
	else
		log_message "$SCRIPT not found or not executable."
		exit 1
	fi
}

log_message "rt-sdk-ara2 installer script started"

if [ "$PCIE_DEVICES" -gt 0 ]; then
	echo ""
	log_message "INFO: Inserting uiodma driver"
	echo ""
	run_script "$BASE_DIR/uiodma_pcie.sh"
fi

for ((i = 0; i < $TOTAL_ARA2_DEVICES; i++)); do
	echo ""
	log_message "INFO: Started Ara2 Hardware Bringup (Device $((i + 1)) of $TOTAL_ARA2_DEVICES)"
	echo ""
	run_script "$BASE_DIR/hw_bringup.sh" $i
	log_message "INFO: Device $((i + 1)) Bringup completed successfully"
done

# run_script "launch_proxy.sh" &
echo ""
log_message " Launching launch_proxy.sh in background "
echo ""

$BASE_DIR/launch_proxy.sh >>"$LOG_FILE" 2>&1 &
TAIL_PID=$!
sleep 1
tail -f "$LOG_FILE" --pid=$TAIL_PID
# Check for success or failure messages
if grep -q "Proxy launched succesfully | Proxy is already running." "$LOG_FILE"; then
	log_message "Proxy launched successfully and device ready to run inferences."
elif grep -q "Proxy failed to initialize" "$LOG_FILE"; then
	log_message "Proxy failed to initialize. Check logs for more details."
	exit 1
fi

log_message "Hardware bringup is done (${TOTAL_ARA2_DEVICES} device(s) configured) and proxy is launched successfully in the background."
echo "Logs saved in: $LOG_FILE"
