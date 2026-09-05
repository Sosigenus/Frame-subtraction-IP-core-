//*****************************************************************//
// Company:      None                                              //
//                                                                 //
// Filename:     axis2buffer.v                                     //
// Version:      v1.0                                              //
// Library:      None                                              //
// Parent:       none                                              //
// Description:  Module receive data to buffer.                    //
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
module axis2buffer #
(
    parameter S_AXI_DATA_WIDTH = 128
)
(
    //System signals
    input  wire clk,
    input  wire resetn,

    //AXI-Stream slave
    input  wire [S_AXI_DATA_WIDTH-1:0]      s_axis_tdata,
    input  wire [S_AXI_DATA_WIDTH/8-1:0]    s_axis_tkeep,
    input  wire                             s_axis_tvalid,
    output wire                             s_axis_tready,
    input  wire                             s_axis_tlast,
    input  wire                             s_axis_tuser,

    //Output signals to buffer
    output wire                         buf_wr_en,
    output wire [S_AXI_DATA_WIDTH-1:0]  buf_wr_data,
    output wire [31:0]                  buf_wr_addr,
    output wire                         buf_wr_last,
    input  wire                         buf_wr_full
);

    //Register for assign
    reg                         buf_wr_en_reg;
    reg [S_AXI_DATA_WIDTH-1:0]  buf_wr_data_reg;
    reg                         buf_wr_last_reg;

    //s_axis_tready
    assign s_axis_tready = ~buf_wr_full;

    //Output signals to buffer
    always @(posedge clk) begin
        if (!resetn) begin
            buf_wr_en_reg   <= 1'b0;
            buf_wr_data_reg <= {S_AXI_DATA_WIDTH{1'b0}};
            buf_wr_last_reg <= 1'b0;
        end
        else begin
            //Handshake
            if (s_axis_tvalid && s_axis_tready) begin
                buf_wr_en_reg   <= 1'b1;
                buf_wr_data_reg <= s_axis_tdata;
                buf_wr_last_reg <= s_axis_tlast;
            end
            else begin
                buf_wr_en_reg   <= 1'b0;
                buf_wr_last_reg <= 1'b0;
            end
        end
    end

    //Assignments
    assign buf_wr_en    = buf_wr_en_reg;
    assign buf_wr_data  = buf_wr_data_reg;
    assign buf_wr_addr  = 32'h0000_0000;
    assign buf_wr_last  = buf_wr_last_reg;

endmodule
`default_nettype wire