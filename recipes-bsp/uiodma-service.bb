# Copyright (C) 2025 Martin Podolszki <m.podolszki@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "systemd service for Kinara ARA2 UIO DMA"

LICENSE = "MIT"
SECTION = "console/network"
LIC_FILES_CHKSUM ="file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
FILESEXTRAPATHS:prepend := "${THISDIR}/uiodma-service:"
SRC_URI = " \
        file://uiodma-bind.service;subdir=${BP} \
        file://kinara-uiodma-bind.sh;subdir=${BP} \
        file://kinara-ara2-flash.sh;subdir=${BP} \
        file://kinara-ara2-bringup.sh;subdir=${BP} \
        file://kinara-ara2.default;subdir=${BP} \
"

SYSTEMD_SERVICE:${PN} = "uiodma-bind.service"
RDEPENDS:${PN} = "systemd kmod pciutils kinara-ddr-bringup"
DEPENDS = "systemd"
inherit systemd
S = "${WORKDIR}/${BP}"

do_install () {

        install -d ${D}${systemd_unitdir}/system
        install -c -m 0644 ${S}/uiodma-bind.service ${D}${systemd_unitdir}/system

        install -d ${D}${sbindir}
        install -m 0755 ${S}/kinara-uiodma-bind.sh ${D}${sbindir}/kinara-uiodma-bind.sh
        install -m 0755 ${S}/kinara-ara2-flash.sh ${D}${sbindir}/kinara-ara2-flash.sh
        install -m 0755 ${S}/kinara-ara2-bringup.sh ${D}${sbindir}/kinara-ara2-bringup.sh

        install -d ${D}${sysconfdir}/default
        install -m 0644 ${S}/kinara-ara2.default ${D}${sysconfdir}/default/kinara-ara2
}

FILES:${PN} += "${systemd_unitdir}/system/uiodma-bind.service"
FILES:${PN} += "${sbindir}/kinara-uiodma-bind.sh"
FILES:${PN} += "${sbindir}/kinara-ara2-flash.sh"
FILES:${PN} += "${sbindir}/kinara-ara2-bringup.sh"
FILES:${PN} += "${sysconfdir}/default/kinara-ara2"

CONFFILES:${PN} += "${sysconfdir}/default/kinara-ara2"

SYSTEMD_AUTO_ENABLE = "enable"
