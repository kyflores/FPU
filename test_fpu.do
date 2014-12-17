vlog -reportprogress 300 -work work complete_add.v adder.v support_modules.v multiplier.v SLT.v fpu.v
vsim -voptargs="+acc" "test_fpu"
add wave -position insertpoint  \
sim:/test_fpu/opA \
sim:/test_fpu/opB \
sim:/test_fpu/result \

run 50000
wave zoom full