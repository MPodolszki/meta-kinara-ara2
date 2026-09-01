DESCRIPTION = "Offline install of uv/uvx (aarch64 prebuilt binary) for Kinara tools"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

UV_VERSION = "0.11.7"

SRC_URI = "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-aarch64-unknown-linux-gnu.tar.gz"
SRC_URI[sha256sum] = "f2ee1cde9aabb4c6e43bd3f341dadaf42189a54e001e521346dc31547310e284"

# tarball extracts into uv-aarch64-unknown-linux-gnu/
S = "${WORKDIR}/uv-aarch64-unknown-linux-gnu"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/uv ${D}${bindir}/uv
    ln -sf uv ${D}${bindir}/uvx
}

FILES:${PN} += "${bindir}/uv ${bindir}/uvx"

INSANE_SKIP:${PN} += "already-stripped ldflags"
