vlib work
vlog Design.v Design_tb.v +cover -covercells
vsim -voptargs=+acc work.Design_tb -cover
add wave *
coverage save DesignCoverage.ucdb -onexit
run -all