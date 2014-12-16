vlog -reportprogress 300 -work work SLT.v adder.v support_modules.v
vsim -voptargs="+acc" "test_SLT"
add wave -position insertpoint  \
sim:test_SLT/res_behavioral \
sim:test_SLT/res_structural \
sim:test_SLT/SLT_test_structural/sub_result \
sim:test_SLT/SLT_test_structural/carryout \
sim:test_SLT/SLT_test_structural/input1 \
sim:test_SLT/SLT_test_structural/input2 \
sim:test_SLT/SLT_test_structural/tempXOR \

run 5000
wave zoom full