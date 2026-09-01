DESCRIPTION = "Kinara Ara2 helper scripts in /usr/bin"
LICENSE = "CLOSED"

KINARA_DATA_DIR = "${THISDIR}/../../data"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    find ${KINARA_DATA_DIR}/usr/bin -type f -print0 | \
        xargs -0 -I '{}' install -m 0755 '{}' ${D}${bindir}/
}

RDEPENDS:${PN} += "kinara-ara2-wheels kinara-ara2-uv"

FILES:${PN} += "${bindir}/*"
