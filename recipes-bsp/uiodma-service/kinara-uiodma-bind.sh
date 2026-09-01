#!/bin/sh
set -eu

UIODMA_VENDOR="${UIODMA_VENDOR:-1e58}"
UIODMA_DEVICE="${UIODMA_DEVICE:-0002}"
UIODMA_FORCE_BAR_ASSIGN="${UIODMA_FORCE_BAR_ASSIGN:-1}"
UIODMA_BAR0_ADDR="${UIODMA_BAR0_ADDR:-0x18100000}"
UIODMA_BAR2_ADDR="${UIODMA_BAR2_ADDR:-0x18200000}"
UIODMA_BAR4_ADDR="${UIODMA_BAR4_ADDR:-0x18300000}"

find_pci_bdf() {
    for d in /sys/bus/pci/devices/*; do
        [ -f "${d}/vendor" ] || continue
        [ -f "${d}/device" ] || continue
        v="$(cat "${d}/vendor")"
        dev="$(cat "${d}/device")"
        if [ "${v}" = "0x${UIODMA_VENDOR}" ] && [ "${dev}" = "0x${UIODMA_DEVICE}" ]; then
            basename "${d}"
            return 0
        fi
    done
    return 1
}

bind_driver() {
    modprobe uiodma
    if [ -w /sys/bus/pci/drivers/uiodma/new_id ]; then
        # "File exists" is fine when ID was already registered
        echo "${UIODMA_VENDOR} ${UIODMA_DEVICE}" > /sys/bus/pci/drivers/uiodma/new_id 2>/dev/null || true
    fi
}

has_uiodma_sysfs() {
    bdf="$1"
    [ -e "/sys/bus/pci/devices/${bdf}/uiodma" ]
}

pcie_rescan_endpoint() {
    bdf="$1"
    if [ -w "/sys/bus/pci/devices/${bdf}/remove" ]; then
        echo 1 > "/sys/bus/pci/devices/${bdf}/remove"
    fi
    if [ -w /sys/bus/pci/rescan ]; then
        echo 1 > /sys/bus/pci/rescan
    fi
}

manual_assign_bars() {
    bdf="$1"
    short_bdf="${bdf#0000:}"

    if ! command -v setpci >/dev/null 2>&1; then
        return 1
    fi

    # BAR0/BAR2/BAR4 are 64-bit prefetchable. Program only low dword, upper=0.
    setpci -s "${short_bdf}" 10.l="${UIODMA_BAR0_ADDR}"
    setpci -s "${short_bdf}" 14.l=0
    setpci -s "${short_bdf}" 18.l="${UIODMA_BAR2_ADDR}"
    setpci -s "${short_bdf}" 1c.l=0
    setpci -s "${short_bdf}" 20.l="${UIODMA_BAR4_ADDR}"
    setpci -s "${short_bdf}" 24.l=0

    # Enable Memory Space + Bus Master
    cmd="$(setpci -s "${short_bdf}" 04.w)"
    new_cmd="$(printf '%04x' $((0x${cmd} | 0x0006)))"
    setpci -s "${short_bdf}" 04.w="${new_cmd}"
}

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root." >&2
    exit 1
fi

if ! command -v modprobe >/dev/null 2>&1; then
    echo "modprobe not found." >&2
    exit 1
fi

bdf="$(find_pci_bdf || true)"
if [ -z "${bdf}" ]; then
    echo "No PCI device ${UIODMA_VENDOR}:${UIODMA_DEVICE} found." >&2
    exit 1
fi

modprobe -r uiodma 2>/dev/null || true
bind_driver

if ! has_uiodma_sysfs "${bdf}"; then
    echo "uiodma node missing after first bind, trying PCIe remove/rescan..." >&2
    pcie_rescan_endpoint "${bdf}"
    sleep 1
    bdf="$(find_pci_bdf || true)"
    if [ -z "${bdf}" ]; then
        echo "Device disappeared after rescan." >&2
        exit 1
    fi

    modprobe -r uiodma 2>/dev/null || true
    bind_driver
fi

if ! has_uiodma_sysfs "${bdf}" && [ "${UIODMA_FORCE_BAR_ASSIGN}" = "1" ]; then
    echo "uiodma still missing, trying manual BAR assignment with setpci..." >&2
    modprobe -r uiodma 2>/dev/null || true
    if manual_assign_bars "${bdf}"; then
        bind_driver
    fi
fi

if ! has_uiodma_sysfs "${bdf}"; then
    echo "uiodma bind failed for ${bdf} (${UIODMA_VENDOR}:${UIODMA_DEVICE})." >&2
    if [ -f "/sys/bus/pci/devices/${bdf}/resource" ]; then
        echo "PCI resource map:" >&2
        cat "/sys/bus/pci/devices/${bdf}/resource" >&2 || true
    fi
    if command -v lspci >/dev/null 2>&1; then
        lspci -nn -s "${bdf#0000:}" -vv 2>/dev/null >&2 || true
    fi
    exit 1
fi

echo "uiodma bound to ${UIODMA_VENDOR}:${UIODMA_DEVICE} at ${bdf}"
lsmod | grep -E '^uiodma\b' || true
