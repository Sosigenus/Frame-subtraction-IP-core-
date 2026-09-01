//*****************************************************************//
// Company:      None                                              //
//                                                                 //
// Filename:     buffer_videostream.v                              //
// Version:      v1.0                                              //
// Library:      None                                              //
// Parent:       none                                              //
// Description:  Module for the accumulation rows (buffering).     //
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
module buffer_videostream #(
    parameter DATA_WIDTH    = 128,
    parameter PIXEL_WIDTH   = 8,
    parameter WIDTH_FRAME   = 1920,
    parameter HEIGHT_FRAME  = 1080
    )
    (
        //System signals
        input wire clk,
        input wire resetn,
        
        //Input signals to buffer
        input   wire                    buf_wr_en,      
        input   wire [DATA_WIDTH-1:0]   buf_wr_data,    
        input   wire [31:0]             buf_wr_addr,   
        input   wire                    buf_wr_last,   
        output  wire                    buf_wr_full,
        
        //Output signals to proccessing
        input  wire                     rd_en,
        output wire [DATA_WIDTH-1:0]    rd_data_a,
        output wire [DATA_WIDTH-1:0]    rd_data_b,
        output wire                     rd_valid,
        input  wire                     rd_ready
    );
    
    //Loop variable
    integer i;
    
    //Register for assign
    reg [DATA_WIDTH-1:0]        rd_data_a_reg;
    reg [31:0]                  rd_data_b_reg;
    reg                         rd_valid_reg;
    
    reg                         buf_wr_full_reg;
    
    //Buffers
    (* ram_style = "block" *)
    reg [PIXEL_WIDTH-1:0] bufferA_ping [0:15360-1];
    (* ram_style = "block" *)
    reg [PIXEL_WIDTH-1:0] bufferA_pong [0:15360-1];
    (* ram_style = "block" *)
    reg [PIXEL_WIDTH-1:0] bufferB_ping [0:15360-1];
    (* ram_style = "block" *)
    reg [PIXEL_WIDTH-1:0] bufferB_pong [0:15360-1];   
    
    
    
    //Assignments
    assign rd_data_a    = rd_data_a_reg;
    assign rd_data_b    = rd_data_b_reg;
    assign rd_valid     = rd_valid_reg;
    assign buf_wr_full  = buf_wr_full_reg;
    
endmodule
`default_nettype wire