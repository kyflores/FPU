vlog -reportprogress 300 -work work multiplier.v support_modules.v adder.v
vsim -voptargs="+acc" "test_negate"
add wave -position insertpoint  \
sim:/test_negate/lol/n_op \
sim:/test_negate/lol/n_result 

run 500
wave zoom full