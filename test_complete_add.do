vlog -reportprogress 300 -work work complete_add.v adder.v support_modules.v multiplier.v SLT.v
vsim -voptargs="+acc" "test_complete_add"
add wave -position insertpoint  \
sim:/test_complete_add/opA \
sim:/test_complete_add/opB \
sim:/test_complete_add/sum \
sim:/test_complete_add/adder01/shifter \
sim:/test_complete_add/adder01/larger \
sim:/test_complete_add/adder01/smaller \
sim:/test_complete_add/adder01/compare \

#sim:/test_complete_add/adder01/valA_bitshift \
#sim:/test_complete_add/adder01/valB_bitshift \

run 5000
wave zoom full