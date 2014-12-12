vlog -reportprogress 300 -work work adder.v
vsim -voptargs="+acc" "test_adder"
add wave -position insertpoint  \
sim:test_adder/out 

run 5000
wave zoom full