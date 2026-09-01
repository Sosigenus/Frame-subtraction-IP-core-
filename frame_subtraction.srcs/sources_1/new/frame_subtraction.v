//*****************************************************************//
// Company:      None                                              //
//                                                                 //
// Filename:     frame_subtraction.v                               //
// Version:      v1.0                                              //
// Library:      None                                              //
// Parent:       none                                              //
// Description:  Module for the Frame subtraction.                 //
//                                                                 //
//               Please refer to the Product Guide for more        //
//               detailed information.                             //
// --------------------------------------------------------------- //
// Author(s):    M. Dumanski                                       //
//                                                                 //
// History:                                                        //
//    29.08.2026 - (v1.0) Initial version                          //
//                                                                 //
//*****************************************************************//
`timescale 1ns / 1ps
`default_nettype none
module frame_subtraction #(
    parameter DATA_WIDTH = 128
    )
    (
        output reg temp = 1'b0,
        //System signals
        input wire clk,
        input wire resetn,
        
        //Input signals to proccessing
        output  wire                    rd_en,
        input   wire [DATA_WIDTH-1:0]   rd_data_a,
        input   wire [DATA_WIDTH-1:0]   rd_data_b,
        input   wire                    rd_valid,
        output  wire                    rd_ready,
        
        //Output signals to AXI-Stream
        output  wire [DATA_WIDTH-1:0]   m_axis_tdata,
        output  wire [DATA_WIDTH/8-1:0] m_axis_tkeep,
        output  wire                    m_axis_tlast,
        input   wire                    m_axis_tready,
        output  wire                    m_axis_tvalid
    );
    
    //Register for assign
    reg [DATA_WIDTH-1:0]    m_axis_tdata_reg;
    reg [DATA_WIDTH/8-1:0]  m_axis_tkeep_reg;
    reg                     m_axis_tlast_reg;
    reg                     m_axis_tvalid_reg;
    
    reg                     rd_en_reg;
    reg                     rd_ready_reg;
    
    

    
    
    
    
    //Assignments
    assign m_axis_tdata     = m_axis_tdata_reg;
    assign m_axis_tkeep     = m_axis_tkeep_reg;
    assign m_axis_tlast     = m_axis_tlast_reg;
    assign m_axis_tvalid    = m_axis_tvalid_reg;
    assign rd_en            = rd_en_reg;
    assign rd_ready         = rd_ready_reg;
    
endmodule
`default_nettype wire