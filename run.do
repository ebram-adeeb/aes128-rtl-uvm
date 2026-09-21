#run.do file for questasim
if [file exists work] { vdel -all }
vlib work
vmap work work
vlog +cover=bcesf AES_Encrypt_Only/*.v -Epretty AES_Encrypt_Files.v
vlog -ccflags "-DAES128=1 -I C-DPI" C-DPI/*.c
vlog -sv UVM/*.sv +cover -covercells
vsim -voptargs=+acc work.top -cover -classdebug -uvmcontrol=all +UVM_VERBOSITY=UVM_HIGH
run 0
add wave /top/DUT/*
coverage save AES_top.ucdb -onexit -du work.AES_Encrypt
transcript file simulation_transcript.log
run -all
transcript file ""
coverage report -detail -cvg -comments -output SFC_cov_rprt.txt {}
# quit -sim
# vcover report AES_top.ucdb -details -annotate -all -output CC_SVA_cov_rprt.txt
# vcover report AES_top.ucdb -du=AES_Encrypt -recursive -assert -directive -cvg -codeAll 