Phytec DDR utility

1. Untar the ddr_bringup_sf_600_1200_new_load_ctrl.tar file
2. Goto ddr_bringup_sf_600_1200_new_load_ctrl
3. for 1066MHz DDR frequency 
	./ddr_bringup_sf_600_1200_new_load_ctrl_arm64 -i pcie -s 1 -g 1 -l 3 -b pytech -m 0 -r 0 -c 35
4. for 900MHz DDR frequency
	./ddr_bringup_sf_600_1200_new_load_ctrl_arm64 -i pcie -s 1 -g 1 -l 2 -b pytech -m 0 -r 0 -c 35
