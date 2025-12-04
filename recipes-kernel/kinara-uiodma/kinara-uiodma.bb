# Copyright (C) 2025 PHYTEC Messtechnik GmbH,
# Author: Martin Podolszki <m.podolszki@phytec.de>
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DESCRIPTION = "Kinara Ara2 UIO DMA kernel module"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file:///home/faeteam/Yocto/imx8mp/phyCONTROL/sources/meta-kinara-ara2/art/LICENSE.txt;md5=609f4b4e754be5a7000f9af9a2d0971e"

inherit module

# SDK liegt direkt im Layer meta-kinara-ara2
KINARA_SDK_DIR ?= "${OEROOT}/../meta-kinara-ara2"

# Dieses Makefile wird ins Workdir kopiert
SRC_URI = "file://Makefile"

S = "${WORKDIR}"

do_compile() {
    # uiodma.c aus dem SDK ins Workdir kopieren
    cp ${KINARA_SDK_DIR}/art/linux/drivers/uiodma/uiodma.c ${S}/

    # Modul im Workdir mit unserem Makefile bauen
    oe_runmake -C ${S} \
        KERNEL_SRC=${STAGING_KERNEL_DIR} \
        ARCH=${ARCH} \
        CROSS_COMPILE=${TARGET_PREFIX}
}

do_install() {
    # Standardpfad für out-of-tree-Module
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/misc
    install -m 0644 \
        ${S}/uiodma.ko \
        ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/misc/
}

# Dieses Paket enthält direkt das Modul
FILES:${PN} += "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/misc/uiodma.ko"

# kinara-uiodma stellt das Kernelmodul-Paket bereit
RPROVIDES:${PN} += "kernel-module-uiodma kernel-module-uiodma-${KERNEL_VERSION}"
RREPLACES:${PN} += "kernel-module-uiodma kernel-module-uiodma-${KERNEL_VERSION}"
RCONFLICTS:${PN} += "kernel-module-uiodma kernel-module-uiodma-${KERNEL_VERSION}"

# Automatische RDEPENDS auf kernel-module-uiodma-* für dieses Recipe leeren
RDEPENDS:${PN} = ""