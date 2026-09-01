#!/usr/bin/env sh

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

export DISPLAY=:0
/usr/bin/xterm -fullscreen -bg black -fg white -e "journalctl -u rt-sdk-ara2 -f"

# /usr/bin/weston-terminal --fullscreen --shell=/bin/sh -c "journalctl -u rt-sdk-ara2 -f"
