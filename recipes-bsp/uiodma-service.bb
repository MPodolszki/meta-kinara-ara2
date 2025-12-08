# Copyright (C) 2025 Martin Podolszki <m.podolszki@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "systemd service for Kinara ARA2 UIO DMA"

LICENSE = "MIT"
SECTION = "console/network"
LIC_FILES_CHKSUM ="file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = "file://uiodma-bind.service"

SYSTEMD_SERVICE_${PN} = "uiodma-bind.service"
RDEPENDS_${PN} = "systemd"
DEPENDS = "systemd"
inherit systemd
S = "${WORKDIR}"

do_install () {

        install -d ${D}${systemd_unitdir}/system
        install -c -m 0755 ${WORKDIR}/uiodma-bind.service ${D}${systemd_unitdir}/system

}

FILES_${PN} += "${base_libdir}/systemd/system/uiodma-bind.service"

SYSTEMD_AUTO_ENABLE = "enable"
