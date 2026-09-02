DESCRIPTION = "Kinara Ara2 runtime tree from data"
LICENSE = "CLOSED"

KINARA_DATA_DIR = "${THISDIR}/../../data"

# Name of the SDK tree inside data/usr/share. The vendor drop is versioned;
# data/usr/share/rt-sdk-ara240 (unversioned) is an empty leftover directory.
KINARA_SDK_TREE = "rt-sdk-ara240_2.0.4"

SRC_URI = ""

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${sysconfdir}/rt-sdk-ara240
    cp -a ${KINARA_DATA_DIR}/etc/rt-sdk-ara240/. ${D}${sysconfdir}/rt-sdk-ara240/

    install -d ${D}${datadir}/${KINARA_SDK_TREE}
    cp -a ${KINARA_DATA_DIR}/usr/share/${KINARA_SDK_TREE}/. ${D}${datadir}/${KINARA_SDK_TREE}/

    install -d ${D}${datadir}/doc
    cp -a ${KINARA_DATA_DIR}/usr/share/doc/. ${D}${datadir}/doc/

    if [ -d ${D}${datadir}/${KINARA_SDK_TREE}/scripts ]; then
        find ${D}${datadir}/${KINARA_SDK_TREE}/scripts -type f -name "*.sh" -exec chmod 0755 {} \;
    fi

    # Binaries that are executed directly by helper scripts.
    if [ -d ${D}${datadir}/${KINARA_SDK_TREE}/hw_utils/bins ]; then
        find ${D}${datadir}/${KINARA_SDK_TREE}/hw_utils/bins -type f -exec chmod 0755 {} \;
    fi
    if [ -f ${D}${datadir}/${KINARA_SDK_TREE}/nnapp/nnapp ]; then
        chmod 0755 ${D}${datadir}/${KINARA_SDK_TREE}/nnapp/nnapp
    fi
    # launch_proxy.sh does "cd $ART_DIR/proxy && ./proxy_ara240", so the
    # binary must be packaged executable in place.
    if [ -f ${D}${datadir}/${KINARA_SDK_TREE}/proxy/proxy_ara240 ]; then
        chmod 0755 ${D}${datadir}/${KINARA_SDK_TREE}/proxy/proxy_ara240
    fi
    if [ -f ${D}${datadir}/${KINARA_SDK_TREE}/scripts/ara2_metrics_bin/hw_metrics.out ]; then
        chmod 0755 ${D}${datadir}/${KINARA_SDK_TREE}/scripts/ara2_metrics_bin/hw_metrics.out
    fi

    # Remove circular symlinks left over from the SDK source tree
    find ${D} -maxdepth 8 -type l | while read lnk; do
        target=$(readlink "$lnk")
        case "$target" in
            ./rt-sdk-ara240_*) rm -f "$lnk" ;;
        esac
    done

    # The shipped configs (proxy_config.yaml et al) reference the unversioned
    # path /usr/share/rt-sdk-ara240. Provide it as a symlink so those paths
    # resolve instead of dangling. Created after the cleanup above so it is
    # not swept away by it.
    ln -sf ${KINARA_SDK_TREE} ${D}${datadir}/rt-sdk-ara240

    # Fix host UID/GID contamination - normalise all ownership to root
    chown -R root:root ${D}

    # The vendor drop ships its directories 0700. That makes the tree
    # unreadable for anything but root on target, and it also collides with
    # kinara-ddr-bringup, which owns ${datadir}/${KINARA_SDK_TREE} and its
    # hw_utils subdirectory at 0755 -- rpm rejects the same path packaged
    # twice with different modes:
    #   file /usr/share/rt-sdk-ara240_2.0.4 conflicts between attempted
    #   installs of kinara-ara2-runtime and kinara-ddr-bringup
    find ${D}${datadir}/${KINARA_SDK_TREE} -type d -exec chmod 0755 {} +
}

FILES:${PN} += " \
    ${sysconfdir}/rt-sdk-ara240 \
    ${datadir}/${KINARA_SDK_TREE} \
    ${datadir}/rt-sdk-ara240 \
"

# proxy_ara240 is a dynamically linked PIE; NEEDED: libdbus-1, libusb-1.0,
# libstdc++, libm, libgcc_s, libc.
# libdbus-1.so.3 lives in dbus-lib, not in the dbus package (which only ships
# the daemon and tools) -- see FILES:${PN}-lib in poky's dbus recipe.
RDEPENDS:${PN} += "libusb1 libstdc++ dbus-lib kinara-ara2-libs"

INSANE_SKIP:${PN} += "already-stripped"
