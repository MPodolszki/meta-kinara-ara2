# meta-kinara-ara2

Yocto meta-layer to integrate Kinara Ara2 SDK on PHYTEC phyBOARD-pollux.

Currently provides:
- `kinara-uiodma`: external kernel module build for Ara2 UIO DMA driver
- `kinara-hwutils`: prebuilt hardware utilities
- `kinara-nnapp`: prebuilt nnapp binary
- `kinara-proxy`: prebuilt proxy binary

Set `KINARA_SDK_DIR` in your `local.conf`, e.g.:

```conf
KINARA_SDK_DIR = "${OEROOT}/../sources/kinara-ara2-sdk"
```

Add the packages to your image, for example:

```bitbake
IMAGE_INSTALL:append = " kinara-uiodma kinara-hwutils kinara-nnapp kinara-proxy"
```
# meta-kinara-ara2
