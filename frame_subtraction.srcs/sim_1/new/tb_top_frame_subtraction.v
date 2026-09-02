//*****************************************************************//
// Company:      None                                              //
//                                                                 //
// Filename:     tb_top_frame_subtraction.v                        //
// Version:      v1.0                                              //
// Library:      None                                              //
// Parent:       none                                              //
// Description:  Top module for the TB frame subtraction core.     //
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
module tb_top_frame_subtraction();
    //Clock
    parameter      SYS_CLK_MHZ		= 200.000;
	localparam     HALF_PERIOD		= 1000.0 / SYS_CLK_MHZ / 2;

    //S_AXI width
    parameter      S_AXI_ADDR_WIDTH = 32;
	parameter      S_AXI_DATA_WIDTH = 128;
	
	//M_AXIS width
	parameter      M_AXIS_DATA_WIDTH = 128;
	
	//INPUT, OUTPUT top level
	//System signals
	reg clk;
	reg resetn;
	//
	//GPIO parameters
	reg [31:0] width_frame;
    reg [31:0] height_frame;
    //
    //AXI4-FULL
    reg [S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr;
    reg [2:0]                       s_axi_awprot;
    wire                            s_axi_awready;
    reg                             s_axi_awvalid;
    //
    reg                             s_axi_bready;
    wire [1:0]                      s_axi_bresp;
    wire                            s_axi_bvalid;
    //
    reg [S_AXI_DATA_WIDTH-1:0]      s_axi_wdata;
    reg                             s_axi_wlast;
    wire                            s_axi_wready;
    reg [S_AXI_DATA_WIDTH/8-1:0]    s_axi_wstrb;
    reg                             s_axi_wvalid;
    //
    //AXI-Stream master
    wire [M_AXIS_DATA_WIDTH-1:0]    m_axis_tdata;
    wire [M_AXIS_DATA_WIDTH/8-1:0]  m_axis_tkeep;
    wire                            m_axis_tlast;
    reg                             m_axis_tready;
    wire                            m_axis_tvalid;

    //Instance top module
    top_frame_subtraction #(
        .S_AXI_ADDR_WIDTH(S_AXI_ADDR_WIDTH),
        .S_AXI_DATA_WIDTH(S_AXI_DATA_WIDTH)
    ) top_frame_subtraction_inst
    (
        .clk            (clk),
        .resetn         (resetn),
        
        .width_frame    (width_frame),
        .height_frame   (height_frame),
        
        
        .s_axi_awaddr   (s_axi_awaddr),
        .s_axi_awprot   (s_axi_awprot),
        .s_axi_awready  (s_axi_awready),
        .s_axi_awvalid  (s_axi_awvalid),
        
        .s_axi_bready   (s_axi_bready),
        .s_axi_bresp    (s_axi_bresp),
        .s_axi_bvalid   (s_axi_bvalid),
        
        .s_axi_wdata    (s_axi_wdata),
        .s_axi_wlast    (s_axi_wlast),
        .s_axi_wready   (s_axi_wready),
        .s_axi_wstrb    (s_axi_wstrb),
        .s_axi_wvalid   (s_axi_wvalid),
        
        
        .m_axis_tdata   (m_axis_tdata),
        .m_axis_tkeep   (m_axis_tkeep),
        .m_axis_tlast   (m_axis_tlast),
        .m_axis_tready  (m_axis_tready),
        .m_axis_tvalid  (m_axis_tvalid)
        
    );
    
    //Tasks
    task axi_write_burst;

        input [31:0] start_addr;
        input integer num_beats;

        integer i;

        begin
            //Address
            @(posedge clk);

            s_axi_awaddr  <= start_addr;
            s_axi_awprot  <= 3'b000;
            s_axi_awvalid <= 1'b1;

            //Wait for AW handshake
            while (!s_axi_awready)
                @(posedge clk);

            @(posedge clk);

            s_axi_awvalid <= 1'b0;

            //Data
            for (i = 0; i < num_beats; i = i + 1) begin

                s_axi_wdata <= {
                    8'h00 + i[7:0],
                    8'h10 + i[7:0],
                    8'h20 + i[7:0],
                    8'h30 + i[7:0],
                    8'h40 + i[7:0],
                    8'h50 + i[7:0],
                    8'h60 + i[7:0],
                    8'h70 + i[7:0],
                    8'h80 + i[7:0],
                    8'h90 + i[7:0],
                    8'hA0 + i[7:0],
                    8'hB0 + i[7:0],
                    8'hC0 + i[7:0],
                    8'hD0 + i[7:0],
                    8'hE0 + i[7:0],
                    8'hF0 + i[7:0]
                };

                s_axi_wstrb <= 16'hFFFF;

                if (i == num_beats-1)
                    s_axi_wlast <= 1'b1;
                else
                    s_axi_wlast <= 1'b0;

                s_axi_wvalid <= 1'b1;


                //Wait for W handshake
                while (!s_axi_wready)
                    @(posedge clk);


                @(posedge clk);

                s_axi_wvalid <= 1'b0;
                s_axi_wlast  <= 1'b0;

            end

            //Response
            s_axi_bready <= 1'b1;

            while (!s_axi_bvalid)
                @(posedge clk);

            @(posedge clk);

            s_axi_bready <= 1'b0;

        end

    endtask

    
    //
    always #HALF_PERIOD clk <= ~clk;
    initial begin
        clk = 1'b0;

        resetn = 1'b0;

        s_axi_awaddr  = 0;
        s_axi_awprot  = 0;
        s_axi_awvalid = 0;

        s_axi_wdata  = 0;
        s_axi_wstrb  = 0;
        s_axi_wvalid = 0;
        s_axi_wlast  = 0;

        s_axi_bready = 0;

        
        
        //Reset
        #100;
        @(posedge clk);
        resetn <= 1'b1;
        @(posedge clk);

        //TEST_1. 8 beat burst
        $display("========================================");
        $display("TEST 1: 8 beat AXI burst");
        $display("========================================");

        axi_write_burst(32'h0000_1000, 128);
        axi_write_burst(32'h0000_1000, 128);
        axi_write_burst(32'h0000_1000, 128);
        axi_write_burst(32'h0000_1000, 128);
        axi_write_burst(32'h0000_1000, 128);
        axi_write_burst(32'h0000_1000, 128);
        axi_write_burst(32'h0000_1000, 128);
        axi_write_burst(32'h0000_1000, 128);
        
        //Wait
        repeat (10)
            @(posedge clk);


        $display("========================================");
        $display("TEST FINISHED");
        $display("========================================");

        $finish;

	end
	
	

endmodule
`default_nettype wire