#!/bin/sh
set -eu

EP="${KINARA_EP:-0}"
HW_UTILS_DIR="${KINARA_HW_UTILS_DIR:-/usr/share/rt-sdk-ara240_2.0.4/hw_utils}"
# Commercial vs Industrial part: override KINARA_FLASH_IMAGE for Industrial
# (${HW_UTILS_DIR}/boot_img/Industrial/Industrial_131073.hex).
FLASH_IMAGE="${KINARA_FLASH_IMAGE:-${HW_UTILS_DIR}/boot_img/Commercial/Commercial_131072.hex}"

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root." >&2
    exit 1
fi

# The SDK ships these either bare or with an _aarch64 suffix depending on
# which drop the layer was populated from. Accept both.
PROGRAM_FLASH=""
for cand in "${HW_UTILS_DIR}/bins/program_flash_aarch64" "${HW_UTILS_DIR}/bins/program_flash"; do
    if [ -x "$cand" ]; then
        PROGRAM_FLASH="$cand"
        break
    fi
done
if [ -z "${PROGRAM_FLASH}" ]; then
    echo "Missing binary: ${HW_UTILS_DIR}/bins/program_flash" >&2
    exit 1
fi

if [ ! -f "${FLASH_IMAGE}" ]; then
    echo "Missing flash image: ${FLASH_IMAGE}" >&2
    exit 1
fi

"/usr/sbin/kinara-uiodma-bind.sh"

cd "${HW_UTILS_DIR}"
"${PROGRAM_FLASH}" -e "${EP}" -f "${FLASH_IMAGE}"

echo "Flash done. Reboot host or reset Ara device to load new firmware."
