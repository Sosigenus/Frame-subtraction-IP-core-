//*****************************************************************//
// Company:      None                                              //
//                                                                 //
// Filename:     top_frame_subtraction.v                           //
// Version:      v1.0                                              //
// Library:      None                                              //
// Parent:       none                                              //
// Description:  Top module for the Frame subtraction core.        //
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
module top_frame_subtraction #(
    parameter INTERFACE_TYPE    = "AXI4_FULL", // AXI4_FULL or AXI_STREAM

    parameter S_AXI_ADDR_WIDTH  = 32,
    parameter S_AXI_DATA_WIDTH  = 128,
    
    parameter WIDTH_FRAME       = 1920,
    parameter HEIGHT_FRAME      = 1080,
    
    parameter M_AXIS_DATA_WIDTH = 128)
    (
    //System signals
    input wire clk,
    input wire resetn,
    
    //GPIO parameter (size frames)
    input wire [31:0] width_frame,
    input wire [31:0] height_frame,
    
    //AXI4-Full slave
    //Address read chanel
    /*
    input   wire [S_AXI_ADDR_WIDTH-1:0]     s_axi_araddr,
    input   wire [1:0]                      s_axi_arburst,
    input   wire [3:0]                      s_axi_arid,
    input   wire [7:0]                      s_axi_arlen,
    input   wire                            s_axi_arlock,
    input   wire [2:0]                      s_axi_arprot,
    output  wire                            s_axi_arready,
    input   wire [2:0]                      s_axi_arsize,
    input   wire                            s_axi_arvalid,
    */
    //Address write chanel
    input   wire [S_AXI_ADDR_WIDTH-1:0]     s_axi_awaddr,
    //input   wire [1:0]                      s_axi_awburst,
    //input   wire [3:0]                      s_axi_awcache,
    //input   wire [3:0]                      s_axi_awid,
    //input   wire [7:0]                      s_axi_awlen,
    //input   wire                            s_axi_awlock,
    input   wire [2:0]                      s_axi_awprot,
    output  wire                            s_axi_awready,
    //input   wire [2:0]                      s_axi_awsize,
    input   wire                            s_axi_awvalid,
    //Response chanel
    //output  wire [3:0]                      s_axi_bid,
    input   wire                            s_axi_bready,
    output  wire [1:0]                      s_axi_bresp,
    output  wire                            s_axi_bvalid,
    //Read chanel 
    /*
    output  wire [S_AXI_DATA_WIDTH-1:0]     s_axi_rdata,
    output  wire [3:0]                      s_axi_rid,
    output  wire                            s_axi_rlast,
    input   wire                            s_axi_rready,
    output  wire [1:0]                      s_axi_rresp,
    output  wire                            s_axi_rvalid,
    */
    //Write chanel
    input   wire [S_AXI_DATA_WIDTH-1:0]     s_axi_wdata,
    input   wire                            s_axi_wlast,
    output  wire                            s_axi_wready,
    input   wire [S_AXI_DATA_WIDTH/8-1:0]   s_axi_wstrb,
    input   wire                            s_axi_wvalid,

    //AXI-Stream slave
    input  wire [S_AXI_DATA_WIDTH-1:0]      s_axis_tdata,
    input  wire [S_AXI_DATA_WIDTH/8-1:0]    s_axis_tkeep,
    input  wire                             s_axis_tvalid,
    output wire                             s_axis_tready,
    input  wire                             s_axis_tlast,
    input  wire                             s_axis_tuser,
    
    //AXI-Stream master
    output wire [M_AXIS_DATA_WIDTH-1:0]     m_axis_tdata,
    output wire [M_AXIS_DATA_WIDTH/8-1:0]   m_axis_tkeep,
    output wire                             m_axis_tlast,
    input  wire                             m_axis_tready,
    output wire                             m_axis_tvalid
    
    );
    
    //temp
    localparam PIXEL_WIDTH  = 8;
    
    //Signals for buffer
    wire                        buf_wr_en;
    wire [S_AXI_DATA_WIDTH-1:0] buf_wr_data;
    wire [31:0]                 buf_wr_addr;
    wire                        buf_wr_last;
    wire                        buf_wr_full;
    
    //Signals for proccessing
    wire                        rd_en;
    wire [S_AXI_DATA_WIDTH-1:0] rd_data_a;
    wire [S_AXI_DATA_WIDTH-1:0] rd_data_b;
    wire                        rd_valid;
    wire                        rd_ready;

    //Instance modules
    generate
        //AXI4-Full
        if (INTERFACE_TYPE == "AXI4_FULL") begin : gen_axif
            axif2buffer #(
                .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
                .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH)
            ) u_axif2buffer (
                .clk            (clk),
                .resetn         (resetn),

                .s_axi_awaddr   (s_axi_awaddr),
                .s_axi_awprot   (s_axi_awprot),
                .s_axi_awvalid  (s_axi_awvalid),
                .s_axi_awready  (s_axi_awready),

                .s_axi_wdata    (s_axi_wdata),
                .s_axi_wstrb    (s_axi_wstrb),
                .s_axi_wvalid   (s_axi_wvalid),
                .s_axi_wready   (s_axi_wready),
                .s_axi_wlast    (s_axi_wlast),

                .s_axi_bresp    (s_axi_bresp),
                .s_axi_bvalid   (s_axi_bvalid),
                .s_axi_bready   (s_axi_bready),

                .buf_wr_en      (buf_wr_en),
                .buf_wr_data    (buf_wr_data),
                .buf_wr_addr    (buf_wr_addr),
                .buf_wr_last    (buf_wr_last),
                .buf_wr_full    (buf_wr_full)
            );
        end

        //AXI-Stream
        else if (INTERFACE_TYPE == "AXI_STREAM") begin : gen_axis
            axis2buffer #(
                .DATA_WIDTH     (S_AXI_DATA_WIDTH),
                .PIXEL_WIDTH    (PIXEL_WIDTH),
                .WIDTH_FRAME    (WIDTH_FRAME),
                .HEIGHT_FRAME   (HEIGHT_FRAME)
            ) u_axis2buffer (
                .clk            (clk),
                .resetn         (resetn),

                .s_axis_tdata   (s_axis_tdata),
                .s_axis_tvalid  (s_axis_tvalid),
                .s_axis_tready  (s_axis_tready),
                .s_axis_tlast   (s_axis_tlast),
                .s_axis_tkeep   (s_axis_tkeep),
                .s_axis_tuser   (s_axis_tuser),

                .buf_wr_en      (buf_wr_en),
                .buf_wr_data    (buf_wr_data),
                .buf_wr_addr    (buf_wr_addr),
                .buf_wr_last    (buf_wr_last),
                //.buf_wr_user    (buf_wr_user),
                .buf_wr_full    (buf_wr_full)
            );
        end
    endgenerate

    buffer_videostream # (
        .DATA_WIDTH     (S_AXI_DATA_WIDTH),
        .PIXEL_WIDTH    (PIXEL_WIDTH),
        .WIDTH_FRAME    (WIDTH_FRAME),
        .HEIGHT_FRAME   (HEIGHT_FRAME)
    ) buffer_videostream_inst
    (
        //System signals
        .clk            (clk),
        .resetn         (resetn),

        //Input signals to buffer
        .buf_wr_en      (buf_wr_en),
        .buf_wr_data    (buf_wr_data),
        .buf_wr_addr    (buf_wr_addr),
        .buf_wr_last    (buf_wr_last),
        .buf_wr_full    (buf_wr_full),

        //Output signals to AXI-Stream
        .rd_en          (rd_en),
        .rd_data_a      (rd_data_a),
        .rd_data_b      (rd_data_b),
        .rd_valid       (rd_valid),
        .rd_ready       (rd_ready)
    );

    frame_subtraction # (
        .DATA_WIDTH(S_AXI_DATA_WIDTH)
    ) frame_subtraction_inst
    (
        .clk            (clk),
        .resetn         (resetn),

        .rd_en          (rd_en),
        .rd_data_a      (rd_data_a),
        .rd_data_b      (rd_data_b),
        .rd_valid       (rd_valid),
        .rd_ready       (rd_ready),

        .m_axis_tdata   (m_axis_tdata),
        .m_axis_tkeep   (m_axis_tkeep),
        .m_axis_tlast   (m_axis_tlast),
        .m_axis_tready  (m_axis_tready),
        .m_axis_tvalid  (m_axis_tvalid)
    );
endmodule
`default_nettype wire