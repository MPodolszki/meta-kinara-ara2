# Copyright (C) 2025 PHYTEC Messtechnik GmbH,
# Author: Martin Podolszki <m.podolszki@phytec.de>

DESCRIPTION = "Kinara Ara2 hardware utilities (prebuilt)"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = " \
    file://bins/active_enable_aarch64 \
    file://bins/chip_info_aarch64 \
    file://bins/program_flash_aarch64 \
    file://bins/program_pll_aarch64 \
"

S = "${UNPACKDIR}"

COMPATIBLE_HOST = "aarch64.*-linux"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}/kinara
    install -m 0755 ${S}/bins/* ${D}${bindir}/kinara/
}

FILES:${PN} += "${bindir}/kinara"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

INSANE_SKIP:${PN} += "already-stripped ldflags"
