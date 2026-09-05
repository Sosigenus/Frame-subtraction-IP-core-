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

	//Size frame
	parameter      WIDTH_FRAME     = 1920;
	parameter      HEIGHT_FRAME    = 1080;

	//M_AXIS width
	parameter      M_AXIS_DATA_WIDTH = 128;

	//INTERFACE_TYPE
	parameter      INTERFACE_TYPE    = "AXI_STREAM"; // AXI4_FULL or AXI_STREAM
	
	//INPUT, OUTPUT top level
	//System signals
	reg clk;
	reg resetn;
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
    //AXI-Stream slave
    reg [S_AXI_DATA_WIDTH-1:0]      s_axis_tdata;
    reg [S_AXI_DATA_WIDTH/8-1:0]    s_axis_tkeep;
    reg                             s_axis_tvalid;
    wire                            s_axis_tready;
    reg                             s_axis_tlast;
    reg                             s_axis_tuser;
    //
    //AXI-Stream master
    wire [M_AXIS_DATA_WIDTH-1:0]    m_axis_tdata;
    wire [M_AXIS_DATA_WIDTH/8-1:0]  m_axis_tkeep;
    wire                            m_axis_tlast;
    reg                             m_axis_tready;
    wire                            m_axis_tvalid;
    wire                            m_axis_tuser;

    //Instance top module
    generate
        if (INTERFACE_TYPE == "AXI4_FULL") begin : gen_axif
            top_frame_subtraction #(
                .INTERFACE_TYPE     (INTERFACE_TYPE),

                .S_AXI_ADDR_WIDTH   (S_AXI_ADDR_WIDTH),
                .S_AXI_DATA_WIDTH   (S_AXI_DATA_WIDTH),

                .WIDTH_FRAME    (WIDTH_FRAME),
                .HEIGHT_FRAME   (HEIGHT_FRAME)
        ) top_frame_subtraction_inst
        (
            .clk            (clk),
            .resetn         (resetn),


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
            .m_axis_tvalid  (m_axis_tvalid),
            .m_axis_tuser   (m_axis_tuser)

        );
        end
        else if (INTERFACE_TYPE == "AXI_STREAM") begin : gen_axis
            top_frame_subtraction #(
                .INTERFACE_TYPE (INTERFACE_TYPE),
                .DATA_WIDTH     (S_AXI_DATA_WIDTH),
                //.PIXEL_WIDTH    (PIXEL_WIDTH),
                .WIDTH_FRAME    (WIDTH_FRAME),
                .HEIGHT_FRAME   (HEIGHT_FRAME)
            ) top_frame_subtraction_inst (
                .clk            (clk),
                .resetn         (resetn),

                .s_axis_tdata   (s_axis_tdata),
                .s_axis_tvalid  (s_axis_tvalid),
                .s_axis_tready  (s_axis_tready),
                .s_axis_tlast   (s_axis_tlast),
                .s_axis_tkeep   (s_axis_tkeep),
                .s_axis_tuser   (s_axis_tuser),

                .m_axis_tdata   (m_axis_tdata),
                .m_axis_tkeep   (m_axis_tkeep),
                .m_axis_tlast   (m_axis_tlast),
                .m_axis_tready  (m_axis_tready),
                .m_axis_tvalid  (m_axis_tvalid),
                .m_axis_tuser   (m_axis_tuser)
            );
        end
    endgenerate

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

    task axi_stream_write_line;
        input integer line_num;
        input integer words_per_line;

        integer i;

        begin
            for (i = 0; i < words_per_line; i = i + 1) begin
                @(posedge clk);
                //Data
                s_axis_tdata <= {
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
                s_axis_tkeep <= 16'hFFFF;
                s_axis_tvalid <= 1'b1;

                //TUSER = 1
                if (line_num == 0 && i == 0) begin
                    s_axis_tuser <= 1'b1;
                end else begin
                    s_axis_tuser <= 1'b0;
                end

                //TLAST = 1
                if (i == words_per_line - 1) begin
                    s_axis_tlast <= 1'b1;
                end else begin
                    s_axis_tlast <= 1'b0;
                end

                //handshake (TREADY = 1)
                while (!s_axis_tready) @(posedge clk);
            end

            //Reset
            @(posedge clk);
            s_axis_tvalid <= 1'b0;
            s_axis_tlast  <= 1'b0;
            s_axis_tuser  <= 1'b0;
        end
    endtask
    
    //
    integer i;
    always #HALF_PERIOD clk <= ~clk;
    initial begin
        clk = 1'b0;
        resetn = 1'b0;

        //AXI4_FULL slave
        s_axi_awaddr  = 0;
        s_axi_awprot  = 0;
        s_axi_awvalid = 0;
        //
        s_axi_wdata  = 0;
        s_axi_wstrb  = 0;
        s_axi_wvalid = 0;
        s_axi_wlast  = 0;
        //
        s_axi_bready = 0;

        //AXI_STREAM slave
        s_axis_tdata  = 0;
        s_axis_tkeep  = 0;
        s_axis_tvalid = 0;
        s_axis_tlast  = 0;
        s_axis_tuser  = 0;

        //AXI_STREAM master
        m_axis_tready = 1;

        //Reset
        #100;
        @(posedge clk);
        resetn <= 1'b1;
        @(posedge clk);

        if (INTERFACE_TYPE == "AXI4_FULL") begin
            //TEST_1.
            $display("========================================");
            $display("TEST: AXI4_FULL");
            $display("========================================");

            axi_write_burst(32'h0000_1000, 120);
            axi_write_burst(32'h0000_1000, 120);
            axi_write_burst(32'h0000_1000, 120);
            axi_write_burst(32'h0000_1000, 120);
            axi_write_burst(32'h0000_1000, 120);
            axi_write_burst(32'h0000_1000, 120);
            axi_write_burst(32'h0000_1000, 120);
            axi_write_burst(32'h0000_1000, 120);
        end else if (INTERFACE_TYPE == "AXI_STREAM") begin
            for (i = 0; i < HEIGHT_FRAME*3; i = i + 1) begin
                axi_stream_write_line(2, 120);
            end
            //TEST_1.
            $display("========================================");
            $display("TEST: AXI_STREAM");
            $display("========================================");
        end


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