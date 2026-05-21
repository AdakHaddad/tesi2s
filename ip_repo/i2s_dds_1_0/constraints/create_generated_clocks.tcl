# Tcl helper: try to locate `internal_mclk` nets and create generated clocks
# Usage: source create_generated_clocks.tcl in Vivado/Tcl console (project open)

# try exact net name first
set nets [get_nets -quiet -hierarchical *internal_mclk]
if {[llength $nets] == 0} {
    # try wildcard search
    set nets [get_nets -quiet -hierarchical *internal_mclk*]
}
if {[llength $nets] == 0} {
    puts "WARNING: could not find net named 'internal_mclk' in the current design.\nPlease inspect net names or run 'report_nets' to discover the correct net."
} else {
    foreach n $nets {
        if {[llength [get_ports -quiet audio_48_clk]] > 0} {
            create_generated_clock -name internal_mclk_from_48 -source [get_ports audio_48_clk] -divide_by 1 $n
            puts "Created generated clock internal_mclk_from_48 for net $n"
        }
        if {[llength [get_ports -quiet audio_44_clk]] > 0} {
            create_generated_clock -name internal_mclk_from_44 -source [get_ports audio_44_clk] -divide_by 1 $n
            puts "Created generated clock internal_mclk_from_44 for net $n"
        }
    }
    # mark groups asynchronous to each other (mutually exclusive selection)
    if {[llength [get_clocks -quiet internal_mclk_from_48]] > 0 && [llength [get_clocks -quiet internal_mclk_from_44]] > 0} {
        set_clock_groups -asynchronous -group [get_clocks internal_mclk_from_48] -group [get_clocks internal_mclk_from_44]
        puts "Marked generated clocks as asynchronous groups"
    }
}
