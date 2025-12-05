./bins/chip_info_aarch64 -e 0
./bins/active_enable_aarch64 -e 0 -m 3 
./bins/program_pll_aarch64 -e 0 -p 0 -d 1
./bins/ddr_unified_config_aarch64 \
-e 0 -s 1 -g 1 -l 2 -w 2 -f 0 -n 0 -u 0 -m 1 -r 0 -b willow \
-o ./ddr_config/ddr_cfg_35.bin
./bins/active_enable_aarch64 -e 0 -m 2
