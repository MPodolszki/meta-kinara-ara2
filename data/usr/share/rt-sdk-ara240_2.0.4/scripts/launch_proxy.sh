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

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Update as needed
ART_DIR="/usr/share/rt-sdk-ara240"
PROXY_DIR="$ART_DIR/proxy"
PROXY_BINARY="proxy_ara240"

# All variable paths
PROXY_CONFIG="/etc/rt-sdk-ara240/proxy_config.yaml"

# Log directory and log files
LOG_DIR="$ART_DIR/saved_logs"
PROXY_LOG_FILE="$LOG_DIR/proxy_logs.txt"
mkdir -p "$LOG_DIR"

# Truncate the log file to replace logs from previous runs
>"$PROXY_LOG_FILE"

# Function to log a message
log_message() {
	local MESSAGE=$1
	local LOG_FILE=$2
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $MESSAGE" | tee -a "$LOG_FILE"
}

# Function to check if the proxy is running
is_proxy_running() {
	pgrep -f "$PROXY_BINARY" >/dev/null
}

# Function to launch the proxy
launch_proxy() {
	if is_proxy_running; then
		log_message "Proxy is already running." "$PROXY_LOG_FILE"
	else
		log_message "Launching proxy..." "$PROXY_LOG_FILE"
		sudo rm -f /var/run/dvproxy.pid
		cd "$PROXY_DIR" || {
			log_message "Error: Failed to navigate to proxy directory: $PROXY_DIR" "$PROXY_LOG_FILE"
			exit 1
		}

		# Start proxy in background, log to terminal + file, detach from shell
		{
			./$PROXY_BINARY -c "$PROXY_CONFIG"
		} 2>&1 | tee "$PROXY_LOG_FILE" &
		PROXY_PID=$!
		disown "$PROXY_PID"

		# Non-blocking wait message
		log_message "Proxy launched in background (PID: $PROXY_PID). Waiting for it to initialize..." "$PROXY_LOG_FILE"

		# Simple loop to check readiness
		for i in {1..120}; do
			if grep -q "device initialization done, device ready to run inferences" "$PROXY_LOG_FILE"; then
				log_message "Proxy launched succesfully" "$PROXY_LOG_FILE"
				return 0
			elif grep -q "DeviceManager : device init failed" "$PROXY_LOG_FILE"; then
				log_message "Proxy failed to initialize. See log: $PROXY_LOG_FILE" "$PROXY_LOG_FILE"
				exit 1
			fi
			sleep 1
		done

		log_message "Timeout: Proxy did not initialize in 120 seconds." "$PROXY_LOG_FILE"
		exit 1
	fi
}

# Main script logic
launch_proxy
