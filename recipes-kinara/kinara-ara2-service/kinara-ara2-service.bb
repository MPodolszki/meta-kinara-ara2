DESCRIPTION = "Kinara Ara2 systemd service"
LICENSE = "CLOSED"

inherit systemd

KINARA_DATA_DIR = "${THISDIR}/../../data"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${KINARA_DATA_DIR}/etc/systemd/system/rt-sdk-ara2.service ${D}${systemd_system_unitdir}/
}

SYSTEMD_SERVICE:${PN} = "rt-sdk-ara2.service"
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

RDEPENDS:${PN} += "kinara-ara2-runtime"

FILES:${PN} += "${systemd_system_unitdir}/rt-sdk-ara2.service"
