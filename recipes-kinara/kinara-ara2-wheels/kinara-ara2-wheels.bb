DESCRIPTION = "Kinara Ara2 Python wheels"
LICENSE = "CLOSED"

KINARA_DATA_DIR = "${THISDIR}/../../data"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

# NOTE: data/usr/share/python-wheels does not exist in this layer -- the
# vendor drop we have does not contain the .whl files. The recipe stays in
# place so the wheels only need to be dropped in, but it must not break the
# build while they are missing.
do_install() {
    install -d ${D}${datadir}/python-wheels

    if [ ! -d ${KINARA_DATA_DIR}/usr/share/python-wheels ]; then
        bbwarn "No Python wheels in ${KINARA_DATA_DIR}/usr/share/python-wheels -- packaging ${PN} empty."
        return
    fi

    find ${KINARA_DATA_DIR}/usr/share/python-wheels -type f -name "*.whl" -print0 | \
        xargs -0 -r -I '{}' install -m 0644 '{}' ${D}${datadir}/python-wheels/
}

pkg_postinst_ontarget:${PN}() {
    if command -v python3 >/dev/null 2>&1; then
        for whl in /usr/share/python-wheels/*.whl; do
            [ -e "$whl" ] || continue
            python3 -m pip install --no-index --no-deps "$whl" || true
        done
    fi
}

RDEPENDS:${PN} += "python3-core python3-pip"

FILES:${PN} += "${datadir}/python-wheels"

ALLOW_EMPTY:${PN} = "1"
