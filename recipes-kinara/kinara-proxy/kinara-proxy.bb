# Copyright (C) 2025 PHYTEC Messtechnik GmbH,
# Author: Martin Podolszki <m.podolszki@phytec.de>

DESCRIPTION = "Kinara Ara2 proxy binary (prebuilt, standalone)"
#
# NOTE: this is the older statically linked proxy_aarch64 and is NOT what the
# runtime uses. rt-sdk-ara2.service / launch_proxy.sh run proxy_ara240 from
# ${datadir}/rt-sdk-ara240/proxy/, shipped by kinara-ara2-runtime. Keep this
# recipe out of images unless you deliberately want the standalone binary.
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "file://proxy_aarch64"

S = "${UNPACKDIR}"

COMPATIBLE_HOST = "aarch64.*-linux"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/proxy_aarch64 ${D}${bindir}/kinara-proxy
}

FILES:${PN} += "${bindir}/kinara-proxy"

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

INSANE_SKIP:${PN} += "already-stripped ldflags"
