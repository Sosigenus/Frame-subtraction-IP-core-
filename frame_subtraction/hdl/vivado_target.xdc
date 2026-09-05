#create_clock -period 5.000 -name clk_200 [get_ports clk]
#set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS18} [get_ports clk]


#set_logic_one           [get_ports resetn];
#set_logic_one           [get_ports width_frame];
#set_logic_one           [get_ports height_frame];

##AXIF
#set_logic_one           [get_ports s_axi_awaddr];
#set_logic_one           [get_ports s_axi_awprot];
#set_logic_unconnected   [get_ports s_axi_awready];
#set_logic_one           [get_ports s_axi_awvalid];
##
#set_logic_one           [get_ports s_axi_bready];
#set_logic_unconnected   [get_ports s_axi_bresp];
#set_logic_unconnected   [get_ports s_axi_bvalid];
##
#set_logic_one           [get_ports s_axi_wdata[*]];
#set_logic_one           [get_ports s_axi_wlast];
#set_logic_unconnected   [get_ports s_axi_wready];
#set_logic_one           [get_ports s_axi_wstrb];
#set_logic_one           [get_ports s_axi_wvalid];

##AXIS
#set_logic_unconnected   [get_ports m_axis_tdata[*]];
#set_logic_unconnected   [get_ports m_axis_tkeep[*]];
#set_logic_unconnected   [get_ports m_axis_tlast];
#set_logic_one           [get_ports m_axis_tready];
#set_logic_unconnected   [get_ports m_axis_tvalid];