# Copyright (C) 2025 PHYTEC Messtechnik GmbH,
# Author: Martin Podolszki <m.podolszki@phytec.de>
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DESCRIPTION = "Kinara Ara2 nnapp binary (prebuilt)"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${KINARA_SDK_DIR}/art/LICENSE.txt;md5=609f4b4e754be5a7000f9af9a2d0971e"

KINARA_SDK_DIR ?= "${OEROOT}/../meta-kinara-ara2"

SRC_URI = "file://nnapp_aarch64"

S = "${WORKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${KINARA_SDK_DIR}/art/linux/aarch64/nnapp/nnapp_aarch64 ${D}${bindir}/nnapp
}

FILES:${PN} += "${bindir}/nnapp"