vlib work

vlog gpu.v
vsim decodeAndMap -t 1ns

log {/*}
add wave {/*}
add wave {/s0/*}
add wave {/c0/*}

force {clock} 0, 1 10ns -r 20ns
force {resetn} 0, 1 20ns
force {shapeselect} 0
force {inputColour} 7
run 4000ns
