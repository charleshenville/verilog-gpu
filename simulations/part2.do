vlib work

vlog part2.v
vsim part2 -t 1ns

log {/*}
add wave {/*}
add wave {/c1/*}
add wave {/d1/*}

force {iClock} 0, 1 10ns -r 20ns
force {iResetn} 0, 1 20ns
force {iPlotBox} 0
force {iBlack} 0
force {iColour} 0
force {iLoadX} 0
force {iXY_Coord} 0
run 20ns

force {iXY_Coord} 7'd4, 7'd1 20ns, 0 60ns
force {iColour} 3'b110, 0 60ns
force {iLoadX} 1, 0 20ns
force {iPlotBox} 0, 1 40ns, 0 60ns
run 800ns

force {iXY_Coord} 7'd4, 7'd1 20ns, 0 60ns
force {iColour} 3'b110
force {iLoadX} 1, 0 20ns
force {iPlotBox} 0, 1 40ns, 0 60ns
run 800ns

force {iBlack} 1, 0 20ns
run 4000ns