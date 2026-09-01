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
# set -x

# Base setup
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ART_DIR="/usr/share/rt-sdk-ara240"
MODELS_BASE_DIR="/usr/share/cnn"
NNAPP_CONFIG="/etc/rt-sdk-ara240/cnn_config.yaml"
LOG_DIR="$ART_DIR/saved_logs"
DUMP_OUTPUT_PATH="$LOG_DIR/device_stats"

mkdir -p "$LOG_DIR"
mkdir -p "$DUMP_OUTPUT_PATH"

NNAPP_BIN="$ART_DIR/nnapp/nnapp"

# Confirm nnapp binary
if [ ! -f "$NNAPP_BIN" ]; then
	echo "[ERROR] nnapp binary not found: $NNAPP_BIN"
	exit 1
fi

# ------------------------------------------
# Step 1: Show Categories
# ------------------------------------------
shopt -s nullglob
CATEGORIES=( ${MODELS_BASE_DIR}/*/ )

if (( ${#CATEGORIES[@]} == 0 )); then
	echo "[ERROR] No Categories where found under ${MODELS_BASE_DIR}/"
  echo " Run fetch_models command to download different CNN Models and try again."
  exit 1
fi


echo "=========================="
echo "Available Model Categories"
echo "=========================="
for i in "${!CATEGORIES[@]}"; do
  echo "  $((i + 1))) $(basename ${CATEGORIES[$i]})"
done
echo "  q) Quit"

read -p "Enter the number corresponding to the category you want to explore: " CATEGORY_NUM
# Handle quit
if [[ "$CATEGORY_NUM" =~ ^[Qq]$ ]]; then
	exit 0
fi

CATEGORY_INDEX=$((CATEGORY_NUM - 1))

if ! [[ "$CATEGORY_NUM" =~ ^[0-9]+$ ]] || [ "$CATEGORY_INDEX" -lt 0 ] || [ "$CATEGORY_INDEX" -ge "${#CATEGORIES[@]}" ]; then
	echo "[ERROR] Invalid category selection."
	exit 1
fi

SELECTED_CATEGORY=$(basename "${CATEGORIES[$CATEGORY_INDEX]}")
CATEGORY_PATH="$MODELS_BASE_DIR/$SELECTED_CATEGORY"

if [ ! -d "$CATEGORY_PATH" ]; then
	echo "[ERROR] No models directory found for $SELECTED_CATEGORY at $CATEGORY_PATH"
	echo " Prior to this script, run fetch_models command to download the necessary model"
	exit 1
fi

# ------------------------------------------
# Step 2: Show Models in Selected Category
# ------------------------------------------
echo "=========================="
echo "Available Models in $SELECTED_CATEGORY"
echo "=========================="

model_entries=()
counter=1

while IFS= read -r -d '' model_dvm; do
	model_dir=$(dirname "$model_dvm")
	model_name=$(basename "$model_dir")
	echo "$counter. $model_name"
	model_entries+=("$model_name:$model_dvm")
	((counter++))
done < <(find "$CATEGORY_PATH" -type f -name "model.dvm" -print0 | sort -z)

if [ ${#model_entries[@]} -eq 0 ]; then
	echo "[ERROR] No models found in $CATEGORY_PATH"
	exit 1
fi

read -p "Enter the number corresponding to the model you want to run or 'q' to exit: " MODEL_NUM

# Handle quit
if [[ "$MODEL_NUM" =~ ^[Qq]$ ]]; then
	exit 0
fi

MODEL_INDEX=$((MODEL_NUM - 1))

if ! [[ "$MODEL_NUM" =~ ^[0-9]+$ ]] || [ "$MODEL_INDEX" -lt 0 ] || [ "$MODEL_INDEX" -ge "${#model_entries[@]}" ]; then
	echo "[ERROR] Invalid model selection."
	exit 1
fi

# ------------------------------------------
# Step 3: Run nnapp
# ------------------------------------------
selected_entry="${model_entries[$MODEL_INDEX]}"
IFS=":" read -r model_name model_dvm <<<"$selected_entry"

echo "[INFO] Selected Model: $SELECTED_CATEGORY:$model_name"
echo "[INFO] Model Path: $model_dvm"

PERF_LOG_FILE="$LOG_DIR/${SELECTED_CATEGORY}_${model_name}_perf_log.txt"
# Truncate the log file to replace logs from previous runs
>"$PERF_LOG_FILE"

PARAM_NAME="0.name=$model_name"
PARAM_PATH="0.path=$model_dvm"
NUM_ITERATIONS="0.iterations=1000"
BATCH_SIZE="0.batch_size=10"
PARAMS="$PARAM_NAME:$PARAM_PATH:$NUM_ITERATIONS:$BATCH_SIZE"

echo "[INFO] Running performance test..."
{
	echo "======== $(date) ========"
	echo "Model: $SELECTED_CATEGORY:$model_name"
	"$NNAPP_BIN" --config "$NNAPP_CONFIG" log --dump-path "$DUMP_OUTPUT_PATH" mode infer async --override "$PARAMS"
} 2>&1 | tee -a "$PERF_LOG_FILE"

status=$?
if [ $status -eq 0 ]; then
	echo "[SUCCESS] Performance test completed. Log saved at $PERF_LOG_FILE"
else
	echo "[ERROR] NNApp failed. Check log: $PERF_LOG_FILE"
	exit $status
fi
