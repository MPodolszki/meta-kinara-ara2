# Copyright (C) 2026 PHYTEC Messtechnik GmbH
# Author: Martin Podolszki <m.podolszki@phytec.de>

SUMMARY = "Kinara Ara2 DDR bring-up utility (ddr_bringup_sf_600_1200_new_load_ctrl)"
DESCRIPTION = "Prebuilt vendor DDR bring-up tool for the Kinara Ara2 (Ara240). \
Replaces the older ddr_unified_config / ddr_cfg_*.bin flow from rt-sdk-ara240 2.0.4. \
Ships the CFG35 LPDDR register set (regcfgid35_lpddr_dec4)."

LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = " \
    file://ddr_bringup_sf_600_1200_new_load_ctrl_arm64 \
    file://libs/arm64/ddr_bin_gen.aarch64.so \
    file://libs/arm64/ddr_cfg_gen.aarch64.so \
    file://libs/arm64/dv_hw_silicon_api.aarch64.so \
    file://libs/arm64/libDvSysApi.aarch64.so \
    file://libs/arm64/libftd2xx.so \
    file://libs/arm64/libyaml-0.so \
    file://libs/arm64/libyaml-0.so.2 \
    file://regcfgid35_lpddr_dec4/ddr_init.bin \
    file://regcfgid35_lpddr_dec4/mem_init.yaml \
    file://regcfgid35_lpddr_dec4/MT53E1G32D2FW_BL16_CL36_2133Mhz_CTL \
    file://regcfgid35_lpddr_dec4/MT53E1G32D2FW_BL16_CL36_2133Mhz_PHY \
    file://regcfgid35_lpddr_dec4/MT53E1G32D2FW_BL16_CL36_2133Mhz_PI \
    file://regcfgid35_lpddr_dec4/README \
    file://README.md \
"

S = "${UNPACKDIR}"

COMPATIBLE_HOST = "aarch64.*-linux"

# Where the bundle lands on target. The binary carries RPATH ".:libs/arm64"
# and resolves its config set relative to $PWD, so it MUST be started from
# inside this directory -- see kinara-ara2-bringup.sh in uiodma-service.
KINARA_DDR_DIR = "${datadir}/rt-sdk-ara240_2.0.4/hw_utils/ddr_bringup"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${KINARA_DDR_DIR}/libs/arm64
    install -d ${D}${KINARA_DDR_DIR}/regcfgid35_lpddr_dec4

    install -m 0755 ${S}/ddr_bringup_sf_600_1200_new_load_ctrl_arm64 ${D}${KINARA_DDR_DIR}/
    install -m 0755 ${S}/libs/arm64/*.so* ${D}${KINARA_DDR_DIR}/libs/arm64/
    install -m 0644 ${S}/regcfgid35_lpddr_dec4/* ${D}${KINARA_DDR_DIR}/regcfgid35_lpddr_dec4/
    install -m 0644 ${S}/README.md ${D}${KINARA_DDR_DIR}/
}

FILES:${PN} = "${KINARA_DDR_DIR}"

# Vendor prebuilts: not built by us, keep them exactly as delivered.
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_SYSROOT_STRIP = "1"

# This binary's DT_NEEDED entries carry a path, not a bare soname
# ("libs/arm64/ddr_bin_gen.aarch64.so"), because the vendor links against the
# bundle layout and resolves it via RPATH ".:libs/arm64". List both spellings
# so the shlib code treats them as private.
PRIVATE_LIBS:${PN} = " \
    ddr_bin_gen.aarch64.so \
    ddr_cfg_gen.aarch64.so \
    dv_hw_silicon_api.aarch64.so \
    libDvSysApi.aarch64.so \
    libftd2xx.so \
    libyaml-0.so \
    libyaml-0.so.2 \
    libs/arm64/*.so* \
"

# INSANE_SKIP "file-rdeps" only silences the QA check -- rpmdeps still emits
# per-file Requires, and dnf then fails do_rootfs with
#   nothing provides libs/arm64/ddr_bin_gen.aarch64.so()(64bit)
# because no package can ever provide a path-qualified soname. Skip file-level
# dependency generation for this package entirely; everything it really needs
# from the rest of the image is declared in RDEPENDS below.
SKIP_FILEDEPS:${PN} = "1"

RDEPENDS:${PN} += "libstdc++"

INSANE_SKIP:${PN} += "already-stripped dev-so ldflags textrel arch libdir staticdev file-rdeps"
