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
        //System signals
        input wire clk,
        input wire resetn,
        
        //Input signals to proccessing
        input   wire [DATA_WIDTH-1:0]   rd_data_a,
        input   wire [DATA_WIDTH-1:0]   rd_data_b,
        input   wire                    rd_valid,
        output  wire                    rd_ready,
        input   wire                    rd_last,
        input   wire                    rd_user,
        
        //Output signals to AXI-Stream
        output  wire [DATA_WIDTH-1:0]   m_axis_tdata,
        output  wire [DATA_WIDTH/8-1:0] m_axis_tkeep,
        output  wire                    m_axis_tlast,
        input   wire                    m_axis_tready,
        output  wire                    m_axis_tvalid,
        output  wire                    m_axis_tuser
    );

    //Register for assign
    reg                     rd_last_reg;
    reg                     rd_user_reg;

    //Register capture data
    reg [DATA_WIDTH-1:0]    a_reg;
    reg [DATA_WIDTH-1:0]    b_reg;
    reg                     capture_valig_reg;

    //Register result
    reg [DATA_WIDTH-1:0]    result_reg;
    reg                     result_valid;
    reg                     result_last;
    reg                     result_user;

    //Capture data
    always @(posedge clk) begin
        if (!resetn) begin
            a_reg <= {DATA_WIDTH{1'b0}};
            b_reg <= {DATA_WIDTH{1'b0}};
            capture_valig_reg <= 1'b0;
            rd_last_reg       <= 1'b0;
            rd_user_reg       <= 1'b0;
        end
        else begin
            if (rd_valid && rd_ready) begin
                a_reg <= rd_data_a;
                b_reg <= rd_data_b;

                capture_valig_reg <= 1'b1;
                rd_last_reg       <= rd_last;
                rd_user_reg       <= rd_user;
            end
            else begin
                capture_valig_reg <= 1'b0;
                rd_last_reg       <= 1'b0;
            end
        end
    end

    //Subtraction
    wire [DATA_WIDTH-1:0] diff; 
    genvar i;
    generate 
        for(i = 0; i < DATA_WIDTH/8; i = i + 1) begin : pixel_pairs
            wire [7:0] a = a_reg[i*8 +: 8];
            wire [7:0] b = b_reg[i*8 +: 8];

            assign diff[i*8 +: 8] = (a > b) ? (a - b) : (b - a);
        end
    endgenerate

    //Result
    always @(posedge clk) begin
        if(!resetn) begin
            result_reg   <= {DATA_WIDTH{1'b0}};
            result_valid <= 1'b0;
            result_last  <= 1'b0;
            result_user  <= 1'b0;
        end
        else begin
            if (capture_valig_reg) begin
                result_reg   <= diff;
                result_valid <= 1'b1;
                result_last  <= rd_last_reg;
                result_user  <= rd_user_reg;
            end
            else begin
                result_valid <= 1'b0;
                result_last  <= 1'b0;
                result_user  <= 1'b0;
            end
        end
    end

    //Assignments
    assign m_axis_tdata  = result_reg;
    assign m_axis_tkeep  = {DATA_WIDTH/8{1'b1}};
    assign m_axis_tlast  = result_last;
    assign m_axis_tvalid = result_valid;
    assign m_axis_tuser  = result_user;
    assign rd_ready      = m_axis_tready;

endmodule
`default_nettype wire