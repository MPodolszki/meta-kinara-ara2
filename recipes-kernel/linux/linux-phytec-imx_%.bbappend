FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
KINARA_SRC_DIR := "${THISDIR}/${PN}"

SRC_URI:append = " \
    file://pci-realloc.cfg \
"

# PCI class fixup for the Kinara Ara-2 [1e58:0002]: the device reports its
# Processing Accelerator class in the prog-if byte, so the base class reads as
# PCI_CLASS_NOT_DEFINED and __dev_sort_resources() never assigns its BARs --
# uiodma then fails with "BAR 0: not claimed; can't enable device".
# Board-independent, so this is deliberately not machine-guarded.
#
# (The equivalent patch form is kept alongside as
# 0003-PCI-quirks-Fix-Kinara-Ara-2-BAR-assignment-by-correc.patch but is not
# wired into SRC_URI; this cp is what actually takes effect.)
do_configure:prepend() {
    cp ${KINARA_SRC_DIR}/quirk-kinara-ara2.c ${S}/drivers/pci/quirk-kinara-ara2.c
    if ! grep -q 'quirk-kinara-ara2' ${S}/drivers/pci/Makefile; then
        echo 'obj-y += quirk-kinara-ara2.o' >> ${S}/drivers/pci/Makefile
    fi
}
