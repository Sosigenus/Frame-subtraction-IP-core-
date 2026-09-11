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

    parameter M_AXI_ADDR_WIDTH  = 32,
    parameter M_AXI_DATA_WIDTH  = 128,
    
    //parameter PIXEL_WIDTH       = 8,
    
    //parameter WIDTH_FRAME       = 1920,
    //parameter HEIGHT_FRAME      = 1080,

    parameter M_AXIS_DATA_WIDTH = 128
)
(
    //System signals
    input wire clk,
    input wire resetn,
    
    //AXI4-Full Master (MM2S)
    //Address channel
    output wire  [M_AXI_ADDR_WIDTH-1:0] m_axi_araddr,
    output wire  [1:0]                  m_axi_arburst,
    output wire  [3:0]                  m_axi_arcache,
    //output wire  [3:0]                  m_axi_arid,
    output wire  [7:0]                  m_axi_arlen,
    //output wire                         m_axi_arlock,
    output wire  [2:0]                  m_axi_arprot,
    input  wire                         m_axi_arready,
    output wire  [2:0]                  m_axi_arsize,
    output wire                         m_axi_arvalid,

    //Read data channel
    input  wire [M_AXI_DATA_WIDTH-1:0]  m_axi_rdata,
    //input  wire [3:0]                   m_axi_rid,
    input  wire                         m_axi_rlast,
    input  wire                         m_axi_rvalid,
    output wire                         m_axi_rready,
    input  wire [1:0]                   m_axi_rresp,

    //GPIO
    input wire [31:0]                   start_addr,
    input wire [31:0]                   width_frame,
    input wire [31:0]                   height_frame,
    input wire                          start,
    output wire                         done,


    //AXI-Stream slave
    input  wire [M_AXI_DATA_WIDTH-1:0]      s_axis_tdata,
    input  wire [M_AXI_DATA_WIDTH/8-1:0]    s_axis_tkeep,
    input  wire                             s_axis_tvalid,
    output wire                             s_axis_tready,
    input  wire                             s_axis_tlast,
    input  wire                             s_axis_tuser,

    //AXI-Stream master
    output wire [M_AXIS_DATA_WIDTH-1:0]     m_axis_tdata,
    output wire [M_AXIS_DATA_WIDTH/8-1:0]   m_axis_tkeep,
    output wire                             m_axis_tlast,
    input  wire                             m_axis_tready,
    output wire                             m_axis_tvalid,
    output wire                             m_axis_tuser
);

    //Signals for buffer
    wire [31:0]                 capture_width_frame;
    wire [31:0]                 capture_height_frame;
    wire                        buf_wr_en;
    wire [M_AXI_DATA_WIDTH-1:0] buf_wr_data;
    wire [M_AXI_ADDR_WIDTH-1:0] buf_wr_addr;
    wire                        buf_wr_last;
    wire                        buf_wr_full;

    //Signals for proccessing
    wire [M_AXI_DATA_WIDTH-1:0] rd_data_a;
    wire [M_AXI_DATA_WIDTH-1:0] rd_data_b;
    wire                        rd_valid;
    wire                        rd_ready;
    wire                        rd_last;
    wire                        rd_user;

    //Instance modules
    generate
        //AXI4-Full
        if (INTERFACE_TYPE == "AXI4_FULL") begin : gen_axif
            axif2buffer #(
                .S_AXI_ADDR_WIDTH   (M_AXI_ADDR_WIDTH),
                .S_AXI_DATA_WIDTH   (M_AXI_DATA_WIDTH),

                .BURST_LEN          (16)
            ) axif2buffer_inst
            (
                .clk                (clk   ),
                .resetn             (resetn),

                .m_axi_araddr       (m_axi_araddr ),
                .m_axi_arburst      (m_axi_arburst),
                .m_axi_arcache      (m_axi_arcache),
                //.m_axi_arid         (m_axi_arid),
                .m_axi_arlen        (m_axi_arlen  ),
                //.m_axi_arlock       (m_axi_arlock),
                .m_axi_arprot       (m_axi_arprot ),
                .m_axi_arready      (m_axi_arready),
                .m_axi_arsize       (m_axi_arsize ),
                .m_axi_arvalid      (m_axi_arvalid),

                .m_axi_rdata        (m_axi_rdata  ),
                //.m_axi_rid          (m_axi_rid),
                .m_axi_rlast        (m_axi_rlast  ),
                .m_axi_rvalid       (m_axi_rvalid ),
                .m_axi_rready       (m_axi_rready ),
                .m_axi_rresp        (m_axi_rresp  ),

                //GPIO
                .start_addr         (start_addr   ),
                .width_frame        (width_frame  ),
                .height_frame       (height_frame ),
                .start              (start        ),
                .done               (done         ),

                //Output
                .capture_width_frame    (capture_width_frame ),
                .capture_height_frame   (capture_height_frame),

                .buf_wr_en          (buf_wr_en  ),
                .buf_wr_data        (buf_wr_data),
                .buf_wr_addr        (buf_wr_addr),
                .buf_wr_last        (buf_wr_last),
                .buf_wr_full        (buf_wr_full)
            );
        end

        //AXI-Stream
        else if (INTERFACE_TYPE == "AXI_STREAM") begin : gen_axis
            axis2buffer #(
                .S_AXIS_DATA_WIDTH    (M_AXI_DATA_WIDTH)
            ) axis2buffer_inst
            (
                .clk            (clk          ),
                .resetn         (resetn       ),

                .width_frame    (width_frame  ),
                .height_frame   (height_frame ),

                .s_axis_tdata   (s_axis_tdata ),
                .s_axis_tvalid  (s_axis_tvalid),
                .s_axis_tready  (s_axis_tready),
                .s_axis_tlast   (s_axis_tlast ),
                .s_axis_tkeep   (s_axis_tkeep ),
                .s_axis_tuser   (s_axis_tuser ),

                //Output
                .capture_width_frame    (capture_width_frame ),
                .capture_height_frame   (capture_height_frame),

                .buf_wr_en      (buf_wr_en  ),
                .buf_wr_data    (buf_wr_data),
                .buf_wr_addr    (buf_wr_addr),
                .buf_wr_last    (buf_wr_last),
                //.buf_wr_user    (buf_wr_user),
                .buf_wr_full    (buf_wr_full)
            );
        end
    endgenerate

    buffer_videostream # (
        .DATA_WIDTH     (M_AXI_DATA_WIDTH)
    ) buffer_videostream_inst
    (
        //System signals
        .clk            (clk   ),
        .resetn         (resetn),

        .width_frame    (capture_width_frame ),
        .height_frame   (capture_height_frame),

        //Input signals to buffer
        .buf_wr_en      (buf_wr_en  ),
        .buf_wr_data    (buf_wr_data),
        .buf_wr_addr    (buf_wr_addr),
        .buf_wr_last    (buf_wr_last),
        .buf_wr_full    (buf_wr_full),

        //Output signals to AXI-Stream
        .rd_data_a      (rd_data_a),
        .rd_data_b      (rd_data_b),
        .rd_valid       (rd_valid ),
        .rd_ready       (rd_ready ),
        .rd_last        (rd_last  ),
        .rd_user        (rd_user  )
    );

    frame_subtraction # (
        .DATA_WIDTH     (M_AXI_DATA_WIDTH)
        //.PIXEL_WIDTH    (PIXEL_WIDTH)
    ) frame_subtraction_inst
    (
        .clk            (clk   ),
        .resetn         (resetn),

        .rd_data_a      (rd_data_a),
        .rd_data_b      (rd_data_b),
        .rd_valid       (rd_valid ),
        .rd_ready       (rd_ready ),
        .rd_last        (rd_last  ),
        .rd_user        (rd_user  ),

        .m_axis_tdata   (m_axis_tdata ),
        .m_axis_tkeep   (m_axis_tkeep ),
        .m_axis_tlast   (m_axis_tlast ),
        .m_axis_tready  (m_axis_tready),
        .m_axis_tvalid  (m_axis_tvalid),
        .m_axis_tuser   (m_axis_tuser )
    );
endmodule
`default_nettype wire