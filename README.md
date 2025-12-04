# meta-kinara-ara2

Yocto meta-layer to integrate Kinara Ara2 SDK on PHYTEC phyBOARD-pollux.

The art folder includes the complete Ara2 SDK v1.3
You might want to remove this folder for a series product
For debugging builds you should add art/linux/aarch64/ to your device (home folder)
This adds specific tools to programm and flash the device und for testing purposes

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

## Steps to enable ara2 device and runtime

export SDK_ROOT=<untar directory path>

Adjust the -e option for each tool to program various endpoints in multiEP setups
For multiEP connected (willow/cyprus):
-e d:0
-e d:1
-e d:2

For multiEP EV board:
-e 0
-e 1
-e 2

1) Compile and insert uiodma driver for pcie:

cd ${SDK_ROOT}/art/linux/drivers/uiodma
make clean
make
insmod uiodma.ko
sudo echo "1e58 0002" > /sys/bus/pci/drivers/uiodma/new_id

verify driver:
lsmod | grep uiodma

2) program_flash

cd ${SDK_ROOT}/art/linux/aarch64/hw_utils
./bins/program_flash_aarch64 -e 0 -f ./boot_img/willow_therm.hex
<reboot the host/ reset ara device to get new firmware loaded on ara device>

3) chip_info

cd ${SDK_ROOT}/art/linux/aarch64/hw_utils
./bins/chip_info_aarch64 -e 0

4) active_enable

cd ${SDK_ROOT}/art/linux/aarch64/hw_utils
./bins/active_enable_aarch64 -e 0 -m 2

5) To display PLL

cd ${SDK_ROOT}/art/linux/aarch64/hw_utils
./bins/program_pll_aarch64 -e 0 -p 0 -d 1

6) To configure ddr

PLL OPTIONS:
-l 1 : 1000MHz
-l 2 : 900MHz
-l 3 : 1066MHz

MEMORY OPTIONS:
-m 0 : 16GB
-m 1 : 8GB

RANK OPTIONS:
-r 0 : Dual rank
-r 1 : Single rank

MultiEP EV board parameter:
-b 06

DDR Command:
cd ${SDK_ROOT}/art/linux/aarch64/hw_utils
./bins/ddr_unified_config_aarch64 -e 0 -s 1 -g 1 -l <1/2/3> -w 2 -f 0 -n 0 -u 0 -m <0/1> -r <0/1> -b <BOARD NAME> -o ./ddr_config/ddr_cfg_35.bin

Sample DDR command for 16GB ddr part, 1066Mhz:
./bins/ddr_unified_config_aarch64 -e 0 -s 1 -g 1 -l 3 -w 2 -f 0 -n 0 -u 0 -m 0 -r 0 -b willow -o ./ddr_config/ddr_cfg_35.bin

DDR commands for multiEP EV board:
PCIE0_endpoint : ./bins/ddr_mem_united_config_aarch64 -e 0 -b 06 -l <1/2/3> -s 1 -g 1 -o ./ddr_config/ddr_cfg_evboard.bin
PCIE1_endpoint : ./bins/ddr_mem_united_config_aarch64 -e 1 -b 06 -l <1/2/3> -s 1 -g 1 -o ./ddr_config/ddr_cfg_evboard.bin
USB_endpoint   : ./bins/ddr_mem_united_config_aarch64 -e 2 -b 06 -l <1/2/3> -s 1 -g 1 -o ./ddr_config/ddr_cfg_evboard.bin

7) Proxy Launch

cd ${SDK_ROOT}/art/linux/aarch64/proxy

./proxy_aarch64 -c ../../config/proxy_config.yaml

8) Nnapp Launch for llm

cd ${SDK_ROOT}/art/linux/aarch64/nnapp

./nnapp_aarch64 -c ../../config/nnapp_sample_config_llm.yaml


9) Commands to push PCIe device from Gen1 to Gen3 in EV2_Board

To check if pcie is gen1(2.5GT/s)  
lspci -vvv -s 0002:01:00  
lspci -vvv -s 0001:01:00 
  
PCIe gen1 mode expected output:
(LnkSta:	Speed 2.5GT/s (downgraded), Width x2 (downgraded))
  
To push pcie to gen3 remove and rescan pcie device  
cd /sys/bus/pci/devices/0002\:01\:00.0 
echo 1 > remove 
cd /sys/bus/pci/devices/0001\:01\:00.0 
echo 1 > remove 
cd /sys/bus/pci/ 
echo 1 > rescan 
  
After rescan check if the device is pushed to gen3(8GT/s)  
lspci -vvv -s 0002:01:00  
lspci -vvv -s 0001:01:00 

PCIe gen3 mode expected output:
LnkSta:	Speed 8GT/s (downgraded), Width x2 (downgraded) -- gen3 

