vlog -reportprogress 300 -work work multiplier.v support_modules.v adder.v
vsim -voptargs="+acc" "test_mult"
add wave -position insertpoint  \
sim:/clk \
sim:/test_mult/reset \
sim:/test_mult/dut/accumulator/dataOut \
sim:/test_mult/dut/acc_if_true/dataOut \
sim:/test_mult/dut/a_lshift/dataOut \
sim:/test_mult/dut/b_rshift/dataOut \
sim:/test_mult/dut/opA_ss \
sim:/test_mult/dut/opB_ss \
sim:/test_mult/dut/outsign \
sim:/test_mult/res_ok 

run 20000
wave zoom full