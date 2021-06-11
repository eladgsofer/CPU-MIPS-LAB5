transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/rtlMips/MIPS.vhd}
vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/rtlMips/IFETCH.VHD}
vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/rtlMips/IDECODE.VHD}
vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/rtlMips/EXECUTE.VHD}
vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/rtlMips/DMEMORY.VHD}
vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/rtlMips/CONTROL.VHD}

vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/quartus/../tb/mips_tester_struct.vhd}
vcom -93 -work work {C:/Users/Boris/Dropbox/CPU CE MARCH 2013/Labs Lectures/Lab3/Lab3/ex9/quartus/../tb/mips_tb_struct.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  MIPS_tb

add wave *
view structure
view signals
run 20 us
