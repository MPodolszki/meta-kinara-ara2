# Copyright (C) 2025 PHYTEC Messtechnik GmbH,
# Author: Martin Podolszki <m.podolszki@phytec.de>

DESCRIPTION = "Kinara Ara2 nnapp binary (prebuilt)"
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "file://nnapp_aarch64"

S = "${UNPACKDIR}"

COMPATIBLE_HOST = "aarch64.*-linux"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/nnapp_aarch64 ${D}${bindir}/nnapp
}

FILES:${PN} += "${bindir}/nnapp"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

INSANE_SKIP:${PN} += "already-stripped ldflags"
