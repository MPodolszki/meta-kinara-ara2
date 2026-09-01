DESCRIPTION = "Kinara Ara2 udev rule"
LICENSE = "CLOSED"

KINARA_DATA_DIR = "${THISDIR}/../../data"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${KINARA_DATA_DIR}/etc/udev/rules.d/99-ara2.rules ${D}${sysconfdir}/udev/rules.d/
}

FILES:${PN} += "${sysconfdir}/udev/rules.d/99-ara2.rules"
