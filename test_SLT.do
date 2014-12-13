vlog -reportprogress 300 -work work SLT.v
vsim -voptargs="+acc" "test_SLT"
add wave -position insertpoint  \
sim:test_SLT/SLT_test/is_true 

run 5000
wave zoom full