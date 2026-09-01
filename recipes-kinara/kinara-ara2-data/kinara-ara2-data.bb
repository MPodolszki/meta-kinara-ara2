DESCRIPTION = "Kinara Ara2 runtime data, services, scripts, udev rules, libraries and wheels"
#
# SUPERSEDED: this is the original catch-all recipe that installed the whole
# data/ tree in one package. Its payload is now fully covered, without file
# conflicts, by kinara-ara2-runtime, -libs, -tools, -examples, -udev and
# -service, which is what the image installs. Kept only as a fallback; do not
# add it to an image alongside those recipes -- they would collide on
# /etc/rt-sdk-ara240, /usr/lib/libara* and /root/Ara2_examples.
LICENSE = "CLOSED"

inherit systemd

KINARA_DATA_DIR = "${THISDIR}/../../data"

# The vendor drop is versioned; data/usr/share/rt-sdk-ara240 (unversioned)
# is an empty leftover directory.
KINARA_SDK_TREE = "rt-sdk-ara240_2.0.4"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    cp -a ${KINARA_DATA_DIR}/etc ${D}/
    cp -a ${KINARA_DATA_DIR}/usr ${D}/

    # Install example scripts under /root as requested.
    install -d ${D}/root/Ara2_examples
    cp -a ${KINARA_DATA_DIR}/usr/share/${KINARA_SDK_TREE}/optimum-ara/examples/. ${D}/root/Ara2_examples/

    # Ensure helper scripts and binaries are executable.
    if [ -d ${D}${bindir} ]; then
        find ${D}${bindir} -type f -exec chmod 0755 {} \;
    fi
    if [ -d ${D}${datadir}/${KINARA_SDK_TREE}/scripts ]; then
        find ${D}${datadir}/${KINARA_SDK_TREE}/scripts -type f -name "*.sh" -exec chmod 0755 {} \;
    fi

    # Configs reference the unversioned path; provide it as a symlink.
    rmdir ${D}${datadir}/rt-sdk-ara240 2>/dev/null || true
    ln -sf ${KINARA_SDK_TREE} ${D}${datadir}/rt-sdk-ara240
}

SYSTEMD_SERVICE:${PN} = "rt-sdk-ara2.service"
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

# Install wheel files as real Python packages on target.
pkg_postinst_ontarget:${PN}() {
    if command -v python3 >/dev/null 2>&1; then
        for whl in /usr/share/python-wheels/*.whl; do
            [ -e "$whl" ] || continue
            python3 -m pip install --no-index --no-deps "$whl" || true
        done
    fi
}

RDEPENDS:${PN} += "python3-core python3-pip"

FILES:${PN} += " \
    /root/Ara2_examples \
"

INSANE_SKIP:${PN} += "already-stripped dev-so staticdev"
