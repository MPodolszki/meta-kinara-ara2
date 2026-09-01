DESCRIPTION = "Kinara Ara2 examples installed to /root/Ara2_examples"
LICENSE = "CLOSED"

KINARA_DATA_DIR = "${THISDIR}/../../data"

# The vendor drop is versioned; data/usr/share/rt-sdk-ara240 (unversioned)
# is an empty leftover directory.
KINARA_SDK_TREE = "rt-sdk-ara240_2.0.4"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}/root/Ara2_examples
    cp -a ${KINARA_DATA_DIR}/usr/share/${KINARA_SDK_TREE}/optimum-ara/examples/. ${D}/root/Ara2_examples/

    find ${D}/root/Ara2_examples -type f -name "*.py" -exec chmod 0644 {} \;

    # Fix host UID/GID contamination
    chown -R root:root ${D}
}

FILES:${PN} += "/root/Ara2_examples"
