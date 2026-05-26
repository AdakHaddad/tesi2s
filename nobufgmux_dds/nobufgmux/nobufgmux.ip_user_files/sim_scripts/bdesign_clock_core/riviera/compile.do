transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/xil_defaultlib
vlib riviera/microblaze_v11_0_16
vlib riviera/microblaze_riscv_v1_0_7
vlib riviera/lmb_v10_v3_0_16
vlib riviera/lmb_bram_if_cntlr_v4_0_27
vlib riviera/blk_mem_gen_v8_4_12
vlib riviera/axi_lite_ipif_v3_0_4
vlib riviera/mdm_riscv_v1_0_7
vlib riviera/proc_sys_reset_v5_0_17
vlib riviera/smartconnect_v1_0
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_register_slice_v2_1_36
vlib riviera/axi_vip_v1_1_22
vlib riviera/axi_uartlite_v2_0_39

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib
vmap microblaze_v11_0_16 riviera/microblaze_v11_0_16
vmap microblaze_riscv_v1_0_7 riviera/microblaze_riscv_v1_0_7
vmap lmb_v10_v3_0_16 riviera/lmb_v10_v3_0_16
vmap lmb_bram_if_cntlr_v4_0_27 riviera/lmb_bram_if_cntlr_v4_0_27
vmap blk_mem_gen_v8_4_12 riviera/blk_mem_gen_v8_4_12
vmap axi_lite_ipif_v3_0_4 riviera/axi_lite_ipif_v3_0_4
vmap mdm_riscv_v1_0_7 riviera/mdm_riscv_v1_0_7
vmap proc_sys_reset_v5_0_17 riviera/proc_sys_reset_v5_0_17
vmap smartconnect_v1_0 riviera/smartconnect_v1_0
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_36 riviera/axi_register_slice_v2_1_36
vmap axi_vip_v1_1_22 riviera/axi_vip_v1_1_22
vmap axi_uartlite_v2_0_39 riviera/axi_uartlite_v2_0_39

vlog -work xilinx_vip  -incr "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/2025.2/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"D:/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/2025.2/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"D:/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_clk_wiz_0_0/bdesign_clock_core_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_clk_wiz_0_0/bdesign_clock_core_clk_wiz_0_0.v" \

vcom -work microblaze_v11_0_16 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/c957/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work microblaze_riscv_v1_0_7 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/404b/hdl/microblaze_riscv_v1_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_microblaze_riscv_0_0/sim/bdesign_clock_core_microblaze_riscv_0_0.vhd" \

vcom -work lmb_v10_v3_0_16 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/dac4/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_dlmb_v10_0/sim/bdesign_clock_core_dlmb_v10_0.vhd" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_ilmb_v10_0/sim/bdesign_clock_core_ilmb_v10_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_27 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/7cd0/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_dlmb_bram_if_cntlr_0/sim/bdesign_clock_core_dlmb_bram_if_cntlr_0.vhd" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_ilmb_bram_if_cntlr_0/sim/bdesign_clock_core_ilmb_bram_if_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_12  -incr -v2k5 "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/42f3/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_lmb_bram_0/sim/bdesign_clock_core_lmb_bram_0.v" \

vcom -work axi_lite_ipif_v3_0_4 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vcom -work mdm_riscv_v1_0_7 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/d25b/hdl/mdm_riscv_v1_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_mdm_1_0/sim/bdesign_clock_core_mdm_1_0.vhd" \

vcom -work proc_sys_reset_v5_0_17 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_rst_clk_wiz_0_100M_0/sim/bdesign_clock_core_rst_clk_wiz_0_100M_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/sim/bd_128c.v" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_1/sim/bd_128c_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/0848/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_2/sim/bd_128c_arinsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_3/sim/bd_128c_rinsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_4/sim/bd_128c_awinsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_5/sim/bd_128c_winsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_6/sim/bd_128c_binsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_7/sim/bd_128c_aroutsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_8/sim/bd_128c_routsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_9/sim/bd_128c_awoutsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_10/sim/bd_128c_woutsw_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_11/sim/bd_128c_boutsw_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_12/sim/bd_128c_arni_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_13/sim/bd_128c_rni_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_14/sim/bd_128c_awni_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_15/sim/bd_128c_wni_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_16/sim/bd_128c_bni_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/3d9a/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_17/sim/bd_128c_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/7785/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_18/sim/bd_128c_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/3051/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_19/sim/bd_128c_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/852f/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_20/sim/bd_128c_s00a2s_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_21/sim/bd_128c_sarn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_22/sim/bd_128c_srn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_23/sim/bd_128c_sawn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_24/sim/bd_128c_swn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_25/sim/bd_128c_sbn_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/fca9/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_26/sim/bd_128c_m00s2a_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_27/sim/bd_128c_m00arn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_28/sim/bd_128c_m00rn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_29/sim/bd_128c_m00awn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_30/sim/bd_128c_m00wn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_31/sim/bd_128c_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/e44a/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_32/sim/bd_128c_m00e_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_33/sim/bd_128c_m01s2a_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_34/sim/bd_128c_m01arn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_35/sim/bd_128c_m01rn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_36/sim/bd_128c_m01awn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_37/sim/bd_128c_m01wn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_38/sim/bd_128c_m01bn_0.sv" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/bd_0/ip/ip_39/sim/bd_128c_m01e_0.sv" \

vcom -work smartconnect_v1_0 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.vhd" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.sv" \

vlog -work axi_infrastructure_v1_1_0  -incr -v2k5 "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_36  -incr -v2k5 "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/bc4b/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_22  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/b16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_smc_0/sim/bdesign_clock_core_axi_smc_0.sv" \

vcom -work axi_uartlite_v2_0_39 -93  -incr \
"../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/eab1/hdl/axi_uartlite_v2_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_axi_uartlite_0_0/sim/bdesign_clock_core_axi_uartlite_0_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/a415" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/f0b6/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/00fe/hdl/verilog" "+incdir+../../../../nobufgmux.gen/sources_1/bd/bdesign_clock_core/ipshared/ec67/hdl" "+incdir+D:/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/2025.2/Vivado/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l microblaze_v11_0_16 -l microblaze_riscv_v1_0_7 -l lmb_v10_v3_0_16 -l lmb_bram_if_cntlr_v4_0_27 -l blk_mem_gen_v8_4_12 -l axi_lite_ipif_v3_0_4 -l mdm_riscv_v1_0_7 -l proc_sys_reset_v5_0_17 -l smartconnect_v1_0 -l axi_infrastructure_v1_1_0 -l axi_register_slice_v2_1_36 -l axi_vip_v1_1_22 -l axi_uartlite_v2_0_39 \
"../../../bd/bdesign_clock_core/ipshared/8743/hdl/i2s_dds_slave_lite_v1_0_S00_AXI.v" \
"../../../bd/bdesign_clock_core/ipshared/8743/hdl/i2s_dds.v" \
"../../../bd/bdesign_clock_core/ip/bdesign_clock_core_i2s_dds_0_0/sim/bdesign_clock_core_i2s_dds_0_0.v" \
"../../../bd/bdesign_clock_core/sim/bdesign_clock_core.v" \

vlog -work xil_defaultlib \
"glbl.v"

