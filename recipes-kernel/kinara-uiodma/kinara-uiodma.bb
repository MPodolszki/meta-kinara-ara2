# Copyright (C) 2025 PHYTEC Messtechnik GmbH,
# Author: Martin Podolszki <m.podolszki@phytec.de>
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DESCRIPTION = "Kinara Ara2 UIO DMA kernel module"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${THISDIR}/../../art/LICENSE.txt;md5=609f4b4e754be5a7000f9af9a2d0971e"

inherit module

# Dieses Makefile wird ins Workdir kopiert
SRC_URI = " \
    file://Makefile;subdir=${BP} \
    file://uiodma.c;subdir=${BP} \
"

S = "${WORKDIR}/${BP}"

do_compile() {
    # Modul im Workdir mit unserem Makefile bauen
    oe_runmake -C ${S} \
        KERNEL_SRC=${STAGING_KERNEL_DIR} \
        ARCH=${ARCH} \
        CROSS_COMPILE=${TARGET_PREFIX}

    # Stage a fresh copy outside ${S} so do_install never reuses an old inode.
    install -m 0644 ${S}/uiodma.ko ${T}/uiodma.ko
}

do_install() {
    # Avoid pseudo path/inode mismatches when KERNEL_VERSION changes between builds.
    rm -rf ${D}${nonarch_base_libdir}/modules

    # Standardpfad für out-of-tree-Module
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/misc
    install -m 0644 \
        ${T}/uiodma.ko \
        ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/misc/uiodma.ko

    # Modul beim Boot automatisch laden
    install -d ${D}${sysconfdir}/modules-load.d
    echo "uiodma" > ${D}${sysconfdir}/modules-load.d/uiodma.conf
}

# Dieses Paket enthält direkt das Modul
FILES:${PN} += "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/misc/uiodma.ko"
FILES:${PN} += "${sysconfdir}/modules-load.d/uiodma.conf"

# kinara-uiodma stellt das Kernelmodul-Paket bereit
RPROVIDES:${PN} += "kernel-module-uiodma kernel-module-uiodma-${KERNEL_VERSION}"
RREPLACES:${PN} += "kernel-module-uiodma kernel-module-uiodma-${KERNEL_VERSION}"
RCONFLICTS:${PN} += "kernel-module-uiodma kernel-module-uiodma-${KERNEL_VERSION}"

# Automatische RDEPENDS auf kernel-module-uiodma-* für dieses Recipe leeren
RDEPENDS:${PN} = ""

# External kernel module debug info often embeds build paths from the workdir.
INSANE_SKIP:${PN}-dbg += "buildpaths"