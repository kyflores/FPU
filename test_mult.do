vlog -reportprogress 300 -work work multiplier.v support_modules.v adder.v complete_add.v
vsim -voptargs="+acc" "test_mult"
add wave -position insertpoint  \
sim:/clk \
sim:/test_mult/reset \
sim:/test_mult/dut/vA24 \
sim:/test_mult/dut/vA32 \
sim:/test_mult/dut/vB24 \
sim:/test_mult/dut/vB32 

run 30000
wave zoom full