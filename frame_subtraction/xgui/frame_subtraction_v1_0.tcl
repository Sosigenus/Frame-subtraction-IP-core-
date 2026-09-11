
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/frame_subtraction_v1_0.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "INTERFACE_TYPE" -parent ${Page_0} -widget comboBox
  #Adding Group
  set Width [ipgui::add_group $IPINST -name "Width" -parent ${Page_0}]
  set_property tooltip {Width} ${Width}
  ipgui::add_param $IPINST -name "M_AXI_ADDR_WIDTH" -parent ${Width}
  ipgui::add_param $IPINST -name "M_AXI_DATA_WIDTH" -parent ${Width} -widget comboBox
  ipgui::add_param $IPINST -name "M_AXIS_DATA_WIDTH" -parent ${Width}

  #Adding Group
  set Size_frame [ipgui::add_group $IPINST -name "Size frame" -parent ${Page_0}]
  set_property tooltip {Size frame} ${Size_frame}
  ipgui::add_static_text $IPINST -name "Size frame (WIDTH_FRAME)" -parent ${Size_frame} -text {<b> WIDTH_FRAME </b> must be a multiple of <b> DATA_WIDTH/8 </b>}



}

proc update_PARAM_VALUE.M_AXIS_DATA_WIDTH { PARAM_VALUE.M_AXIS_DATA_WIDTH PARAM_VALUE.M_AXI_DATA_WIDTH } {
	# Procedure called to update M_AXIS_DATA_WIDTH when any of the dependent parameters in the arguments change
	
	set M_AXIS_DATA_WIDTH ${PARAM_VALUE.M_AXIS_DATA_WIDTH}
	set M_AXI_DATA_WIDTH ${PARAM_VALUE.M_AXI_DATA_WIDTH}
	set values(M_AXI_DATA_WIDTH) [get_property value $M_AXI_DATA_WIDTH]
	set_property value [gen_USERPARAMETER_M_AXIS_DATA_WIDTH_VALUE $values(M_AXI_DATA_WIDTH)] $M_AXIS_DATA_WIDTH
}

proc validate_PARAM_VALUE.M_AXIS_DATA_WIDTH { PARAM_VALUE.M_AXIS_DATA_WIDTH } {
	# Procedure called to validate M_AXIS_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.INTERFACE_TYPE { PARAM_VALUE.INTERFACE_TYPE } {
	# Procedure called to update INTERFACE_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INTERFACE_TYPE { PARAM_VALUE.INTERFACE_TYPE } {
	# Procedure called to validate INTERFACE_TYPE
	return true
}

proc update_PARAM_VALUE.M_AXI_ADDR_WIDTH { PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to update M_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AXI_ADDR_WIDTH { PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to validate M_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.M_AXI_DATA_WIDTH { PARAM_VALUE.M_AXI_DATA_WIDTH } {
	# Procedure called to update M_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AXI_DATA_WIDTH { PARAM_VALUE.M_AXI_DATA_WIDTH } {
	# Procedure called to validate M_AXI_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.INTERFACE_TYPE { MODELPARAM_VALUE.INTERFACE_TYPE PARAM_VALUE.INTERFACE_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INTERFACE_TYPE}] ${MODELPARAM_VALUE.INTERFACE_TYPE}
}

proc update_MODELPARAM_VALUE.M_AXIS_DATA_WIDTH { MODELPARAM_VALUE.M_AXIS_DATA_WIDTH PARAM_VALUE.M_AXIS_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXIS_DATA_WIDTH}] ${MODELPARAM_VALUE.M_AXIS_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.M_AXI_ADDR_WIDTH { MODELPARAM_VALUE.M_AXI_ADDR_WIDTH PARAM_VALUE.M_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.M_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.M_AXI_DATA_WIDTH { MODELPARAM_VALUE.M_AXI_DATA_WIDTH PARAM_VALUE.M_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.M_AXI_DATA_WIDTH}
}

