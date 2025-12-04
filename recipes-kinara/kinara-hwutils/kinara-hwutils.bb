# Copyright (C) 2025 PHYTEC Messtechnik GmbH,
# Author: Martin Podolszki <m.podolszki@phytec.de>
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DESCRIPTION = "Kinara Ara2 hardware utilities (prebuilt)"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${KINARA_SDK_DIR}/art/LICENSE.txt;md5=609f4b4e754be5a7000f9af9a2d0971e"

KINARA_SDK_DIR ?= "${OEROOT}/../meta-kinara-ara2"

# Kein Fetch notwendig, alles kommt aus KINARA_SDK_DIR
SRC_URI = ""

S = "${WORKDIR}"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}/kinara

    # Alle Dateien (rekursiv) aus hw_utils/bins nach ${bindir}/kinara kopieren
    find ${KINARA_SDK_DIR}/art/linux/aarch64/hw_utils/bins -type f -print0 | \
        xargs -0 -I '{}' install -m 0755 '{}' ${D}${bindir}/kinara/
}

FILES:${PN} += "${bindir}/kinara"
