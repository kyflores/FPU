vlog -reportprogress 300 -work work multiplier.v support_modules.v
vsim -voptargs="+acc" "test_mult"
add wave -position insertpoint  \
sim:/clk \
sim:/test_mult/reset \
sim:/test_mult/dut/accumulator/dataOut \
sim:/test_mult/dut/acc_if_true/dataOut \
sim:/test_mult/dut/a_lshift/dataOut \
sim:/test_mult/dut/b_rshift/dataOut \
sim:/test_mult/dut/adder/opA \
sim:/test_mult/dut/adder/opB \
sim:/test_mult/dut/adder/res 

run 10000
wave zoom full