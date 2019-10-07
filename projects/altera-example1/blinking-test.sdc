create_clock -name main_clk_50MHz -period 20 [get_ports clk_50M] 

#create_generated_clock -name main_clk_5MHz -source [get_ports {clk_50M}] [get_registers {clk_5M}]
create_generated_clock -name main_clk_1Hz -source [get_ports {clk_50M}] [get_registers {clock_divider:clk_divider_0|clk_out}]
#
#create_generated_clock -source [get_ports {clk_50M}] \
#	[get_registers {internal_system:internal_system_unit0|hx8352_controller:hx8352_controller_unit0|hx8352_delay_ms:hx8352_delay_ms_unit|counter:counter_base_unit|r_reg[0]}]
#
#create_generated_clock -source [get_ports {clk_50M}] \
#	[get_registers {internal_system:internal_system_unit0|hx8352_controller:hx8352_controller_unit0|fsm_clk_reg}]
#
#create_generated_clock -source [get_ports {clk_50M}] \
#	[get_registers {internal_system:internal_system_unit0|hx8352_controller:hx8352_controller_unit0|hx8352_reset_generator:hx8352_reset_generator_unit|counter:counter_reset_generator_unit|r_reg[0]}]
#
#create_generated_clock -source [get_ports {clk_50M}] \
#	[get_registers {internal_system:internal_system_unit0|counter:counter_base_unit0|r_reg[0]}]


#create_generated_clock -name secondary_clk_5MHz -source [get_ports {PIN_T2}] [get_nets {internal_system_unit0|hx8352_controller_unit0|fsm_clk_reg}]


derive_pll_clocks
derive_clock_uncertainty

#create_generated_clock -name hx8351_fsm_clk -source [get_nets {internal_system_unit0|hx8352_controller_unit0|fsm_clk_reg}] -master_clock secondary_clk_5MHz
#create_generated_clock -name secondary_clk_5MHz -source [get_ports {PIN_T2}] 
