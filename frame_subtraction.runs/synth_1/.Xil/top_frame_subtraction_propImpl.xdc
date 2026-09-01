set_property SRC_FILE_INFO {cfile:E:/projects_vivado/frame_subtraction/frame_subtraction.srcs/constrs_1/new/vivado_target.xdc rfile:../../../frame_subtraction.srcs/constrs_1/new/vivado_target.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:2 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS18} [get_ports clk]
set_property src_info {type:XDC file:1 line:5 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports resetn];
set_property src_info {type:XDC file:1 line:6 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports width_frame];
set_property src_info {type:XDC file:1 line:7 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports height_frame];
set_property src_info {type:XDC file:1 line:10 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_awaddr];
set_property src_info {type:XDC file:1 line:11 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_awprot];
set_property src_info {type:XDC file:1 line:12 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports s_axi_awready];
set_property src_info {type:XDC file:1 line:13 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_awvalid];
set_property src_info {type:XDC file:1 line:15 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_bready];
set_property src_info {type:XDC file:1 line:16 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports s_axi_bresp];
set_property src_info {type:XDC file:1 line:17 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports s_axi_bvalid];
set_property src_info {type:XDC file:1 line:19 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_wdata[*]];
set_property src_info {type:XDC file:1 line:20 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_wlast];
set_property src_info {type:XDC file:1 line:21 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports s_axi_wready];
set_property src_info {type:XDC file:1 line:22 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_wstrb];
set_property src_info {type:XDC file:1 line:23 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports s_axi_wvalid];
set_property src_info {type:XDC file:1 line:26 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports m_axis_tdata[*]];
set_property src_info {type:XDC file:1 line:27 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports m_axis_tkeep[*]];
set_property src_info {type:XDC file:1 line:28 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports m_axis_tlast];
set_property src_info {type:XDC file:1 line:29 export:INPUT save:INPUT read:READ} [current_design]
set_logic_one           [get_ports m_axis_tready];
set_property src_info {type:XDC file:1 line:30 export:INPUT save:INPUT read:READ} [current_design]
set_logic_unconnected   [get_ports m_axis_tvalid];
