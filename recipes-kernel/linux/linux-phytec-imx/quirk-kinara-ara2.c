// SPDX-License-Identifier: GPL-2.0
/*
 * Kinara Ara-2 PCIe AI accelerator PCI class fixup
 *
 * The Kinara Ara-2 [1e58:0002] reports PCI class 0x000012.  The base
 * class for Processing Accelerators is 0x12, but the device firmware
 * places it in the programming interface byte instead of the base class
 * byte, leaving the effective base class as 0x00 (PCI_CLASS_NOT_DEFINED).
 *
 * The kernel's __dev_sort_resources() in setup-bus.c skips devices whose
 * (class >> 8) equals PCI_CLASS_NOT_DEFINED, so the device's BARs are
 * never added to the resource allocation list and remain unassigned.
 *
 * Without this fix all three 64-bit prefetchable BARs (16 KiB + 1 MiB +
 * 1 MiB) stay at address 0 and the uiodma driver fails with:
 *   "BAR 0: not claimed; can't enable device"
 *
 * Fix by reclassifying the device as Processing Accelerator (0x1200).
 */

#include <linux/pci.h>

static void quirk_kinara_ara2_class(struct pci_dev *dev)
{
	u32 class = dev->class;

	dev->class = PCI_CLASS_ACCELERATOR_PROCESSING << 8;
	pci_info(dev, "PCI class overridden (%#08x -> %#08x)\n",
		 class, dev->class);
}
DECLARE_PCI_FIXUP_CLASS_EARLY(0x1e58, 0x0002,
			      PCI_CLASS_NOT_DEFINED, 8,
			      quirk_kinara_ara2_class);
