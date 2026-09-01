#!/bin/sh
# Kinara Ara2 (Ara240) bring-up: PLL + DDR training.
#
# DDR training uses the vendor bundle ddr_bringup_sf_600_1200_new_load_ctrl,
# installed by the kinara-ddr-bringup recipe. It replaces the older
# ddr_unified_config / ddr_cfg_*.bin flow from rt-sdk-ara240 2.0.4.
#
# The bringup binary carries RPATH ".:libs/arm64" and looks up its register
# set (regcfgid<N>_lpddr_dec4) relative to $PWD, so it must be started from
# inside its own directory.
set -eu

EP="${KINARA_EP:-0}"
HW_UTILS_DIR="${KINARA_HW_UTILS_DIR:-/usr/share/rt-sdk-ara240_2.0.4/hw_utils}"
DDR_DIR="${KINARA_DDR_DIR:-${HW_UTILS_DIR}/ddr_bringup}"
DDR_TOOL="${KINARA_DDR_TOOL:-ddr_bringup_sf_600_1200_new_load_ctrl_arm64}"

# DDR PLL level: 2 = 900 MHz (default), 3 = 1066 MHz.
DDR_PLL="${KINARA_DDR_PLL:-2}"
DDR_MEM="${KINARA_DDR_MEM:-0}"
DDR_RANK="${KINARA_DDR_RANK:-0}"
DDR_CFG_ID="${KINARA_DDR_CFG_ID:-35}"
DDR_IFACE="${KINARA_DDR_IFACE:-pcie}"
BOARD_NAME="${KINARA_BOARD_NAME:-pytech}"

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root." >&2
    exit 1
fi

# The SDK ships these either bare or with an _aarch64 suffix depending on
# which drop the layer was populated from. Accept both.
hw_util() {
    for cand in "${HW_UTILS_DIR}/bins/$1_aarch64" "${HW_UTILS_DIR}/bins/$1"; do
        if [ -x "$cand" ]; then
            echo "$cand"
            return 0
        fi
    done
    echo "Missing binary: ${HW_UTILS_DIR}/bins/$1" >&2
    return 1
}

CHIP_INFO=$(hw_util chip_info)
ACTIVE_ENABLE=$(hw_util active_enable)
PROGRAM_PLL=$(hw_util program_pll)

if [ ! -x "${DDR_DIR}/${DDR_TOOL}" ]; then
    echo "Missing DDR bring-up tool: ${DDR_DIR}/${DDR_TOOL}" >&2
    exit 1
fi
if [ ! -d "${DDR_DIR}/regcfgid${DDR_CFG_ID}_lpddr_dec4" ]; then
    echo "Missing DDR register set: ${DDR_DIR}/regcfgid${DDR_CFG_ID}_lpddr_dec4" >&2
    exit 1
fi

"/usr/sbin/kinara-uiodma-bind.sh"

"${CHIP_INFO}" -e "${EP}"
"${ACTIVE_ENABLE}" -e "${EP}" -m 3
"${PROGRAM_PLL}" -e "${EP}" -p 0 -d 1

# Must run with the bundle directory as CWD (see header).
cd "${DDR_DIR}"
./"${DDR_TOOL}" \
    -i "${DDR_IFACE}" -s 1 -g 1 -l "${DDR_PLL}" \
    -b "${BOARD_NAME}" -m "${DDR_MEM}" -r "${DDR_RANK}" -c "${DDR_CFG_ID}"

"${ACTIVE_ENABLE}" -e "${EP}" -m 2

echo "Bringup sequence completed for endpoint ${EP} (DDR PLL level ${DDR_PLL}, cfg ${DDR_CFG_ID})."
