# Generated-clock constraints for i2s IP
# Create generated clocks for `internal_mclk` driven by audio clocks.
# Adjust net/port names if your top-level packaging changes.

# In this updated design, `internal_mclk` is at the same frequency as the
# input audio clocks (no division in clk_mux). The main module then
# divides it by 2 to produce i2s_mclk.

# Generated clock from 48-family audio clock (divide by 1 -> mclk)
create_generated_clock -name internal_mclk_from_48 -source [get_ports audio_48_clk] -divide_by 1 [get_nets -hierarchical *internal_mclk]

# Generated clock from 44-family audio clock (divide by 1 -> mclk)
create_generated_clock -name internal_mclk_from_44 -source [get_ports audio_44_clk] -divide_by 1 [get_nets -hierarchical *internal_mclk]

# Mark groups asynchronous to each other (mutually exclusive selection)
set_clock_groups -asynchronous -group [get_clocks internal_mclk_from_48] -group [get_clocks internal_mclk_from_44]

# CDC False Path for the FS_FAMILY select bit
# This bit is changed by the CPU (AXI domain) and consumed by the clk_mux
# (audio domains). It is synchronized by a multi-stage handshake, so we
# can safely ignore the timing path from the AXI register.
set_false_path -from [get_cells -hierarchical *slv_reg2_reg[2]] -to [get_cells -hierarchical *mclk_mux_inst/q*_d1_reg*]
