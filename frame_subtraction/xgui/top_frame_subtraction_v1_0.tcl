# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "INTERFACE_TYPE" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "S_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "M_AXIS_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_FRAME" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HEIGHT_FRAME" -parent ${Page_0}


}

proc update_PARAM_VALUE.HEIGHT_FRAME { PARAM_VALUE.HEIGHT_FRAME } {
	# Procedure called to update HEIGHT_FRAME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HEIGHT_FRAME { PARAM_VALUE.HEIGHT_FRAME } {
	# Procedure called to validate HEIGHT_FRAME
	return true
}

proc update_PARAM_VALUE.INTERFACE_TYPE { PARAM_VALUE.INTERFACE_TYPE } {
	# Procedure called to update INTERFACE_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INTERFACE_TYPE { PARAM_VALUE.INTERFACE_TYPE } {
	# Procedure called to validate INTERFACE_TYPE
	return true
}

proc update_PARAM_VALUE.M_AXIS_DATA_WIDTH { PARAM_VALUE.M_AXIS_DATA_WIDTH } {
	# Procedure called to update M_AXIS_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AXIS_DATA_WIDTH { PARAM_VALUE.M_AXIS_DATA_WIDTH } {
	# Procedure called to validate M_AXIS_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to update S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to validate S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to update S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to validate S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.WIDTH_FRAME { PARAM_VALUE.WIDTH_FRAME } {
	# Procedure called to update WIDTH_FRAME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_FRAME { PARAM_VALUE.WIDTH_FRAME } {
	# Procedure called to validate WIDTH_FRAME
	return true
}


proc update_MODELPARAM_VALUE.INTERFACE_TYPE { MODELPARAM_VALUE.INTERFACE_TYPE PARAM_VALUE.INTERFACE_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INTERFACE_TYPE}] ${MODELPARAM_VALUE.INTERFACE_TYPE}
}

proc update_MODELPARAM_VALUE.S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.S_AXI_ADDR_WIDTH PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.S_AXI_DATA_WIDTH { MODELPARAM_VALUE.S_AXI_DATA_WIDTH PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.WIDTH_FRAME { MODELPARAM_VALUE.WIDTH_FRAME PARAM_VALUE.WIDTH_FRAME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_FRAME}] ${MODELPARAM_VALUE.WIDTH_FRAME}
}

proc update_MODELPARAM_VALUE.HEIGHT_FRAME { MODELPARAM_VALUE.HEIGHT_FRAME PARAM_VALUE.HEIGHT_FRAME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HEIGHT_FRAME}] ${MODELPARAM_VALUE.HEIGHT_FRAME}
}

proc update_MODELPARAM_VALUE.M_AXIS_DATA_WIDTH { MODELPARAM_VALUE.M_AXIS_DATA_WIDTH PARAM_VALUE.M_AXIS_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXIS_DATA_WIDTH}] ${MODELPARAM_VALUE.M_AXIS_DATA_WIDTH}
}

