DESCRIPTION = "Kinara Ara2 user-space libraries"
LICENSE = "CLOSED"

PROVIDES += "ara2"

KINARA_DATA_DIR = "${THISDIR}/../../data"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

# Keep plain .so files in ${PN}; this SDK ships non-symlink .so artifacts.
SOLIBS = ".so.*"
FILES_SOLIBSDEV = ""

do_install() {
    install -d ${D}${libdir}
    install -d ${D}${includedir}
    
    # Install all files
    cp -a ${KINARA_DATA_DIR}/usr/lib/. ${D}${libdir}/
    cp -a ${KINARA_DATA_DIR}/usr/include/. ${D}${includedir}/
    # The vendor headers use quoted sibling includes (dvapi.h pulls in
    # "dv_status_codes.h", core.h/runner.h pull in "common_types.h" and
    # "core_api.h"). GCC resolves a quoted include relative to the directory of
    # the file *as it was opened* -- for a flat symlink in ${includedir} that is
    # ${includedir}, not sdk_ara/. So a single dvapi.h symlink is not enough:
    # every header needs a flat alias, otherwise consumers such as nnstreamer's
    # ara2 tensor_filter fail with "dv_status_codes.h: No such file or directory".
    for hdr in ${D}${includedir}/sdk_ara/*.h; do
        ln -sf sdk_ara/$(basename $hdr) ${D}${includedir}/$(basename $hdr)
    done
    ln -sf libaraclient_aarch64.so ${D}${libdir}/libaraclient.so
    ln -sf libaraclient_aarch64.so ${D}${libdir}/libaraclient.so.1
    
    # Ensure gstreamer plugins are executable
    if [ -d ${D}${libdir}/gstreamer-1.0 ]; then
        find ${D}${libdir}/gstreamer-1.0 -type f -exec chmod 0755 {} \;
    fi

    # Fix host UID/GID contamination
    chown -R root:root ${D}
}

# Split gstreamer plugins into a separate package while keeping default packages
PACKAGES += "${PN}-gstreamer-plugins"

# Include all libara* files (versioned .so, .a, and debug variants)
FILES:${PN} = "${libdir}/libara* ${includedir}/sdk_ara ${includedir}/*.h"
# Include gstreamer-1.0 plugins (exclude .debug which Yocto auto-creates)
FILES:${PN}-gstreamer-plugins = "${libdir}/gstreamer-1.0/*.so"
FILES:${PN}-dbg += "${libdir}/gstreamer-1.0/.debug ${libdir}/gstreamer-1.0/.debug/*"

RDEPENDS:${PN} += "gstreamer1.0 glib-2.0"
RDEPENDS:${PN}-gstreamer-plugins += "gstreamer1.0 glib-2.0"
RPROVIDES:${PN} += "ara2"

INSANE_SKIP:${PN} += "already-stripped dev-so staticdev"
INSANE_SKIP:${PN}-gstreamer-plugins += "already-stripped file-rdeps"
