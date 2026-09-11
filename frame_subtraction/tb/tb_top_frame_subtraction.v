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

    //M_AXI width
    parameter      M_AXI_ADDR_WIDTH = 32;
	parameter      M_AXI_DATA_WIDTH = 128;

	//M_AXIS width
	parameter      M_AXIS_DATA_WIDTH = 128;

	//INTERFACE_TYPE
	parameter      INTERFACE_TYPE    = "AXI4_FULL"; // AXI4_FULL or AXI_STREAM
	
	//INPUT, OUTPUT top level
	//System signals
	reg clk;
	reg resetn;
	//
	//Size frame
	reg [31:0] width_frame;
	reg [31:0] height_frame;
    //
    //AXI4-Full Master (MM2S)
    //Address channel
    wire  [M_AXI_ADDR_WIDTH-1:0]    m_axi_araddr;
    wire  [1:0]                     m_axi_arburst;
    wire  [3:0]                     m_axi_arcache;
    //wire  [3:0]                     m_axi_arid;
    wire  [7:0]                     m_axi_arlen;
    //wire                            m_axi_arlock;
    wire  [2:0]                     m_axi_arprot;
    reg                             m_axi_arready;
    wire  [2:0]                     m_axi_arsize;
    wire                            m_axi_arvalid;
    //
    //Read data channel
    reg [M_AXI_DATA_WIDTH-1:0]      m_axi_rdata;
    //reg [3:0]                       m_axi_rid,
    reg                             m_axi_rlast;
    reg                             m_axi_rvalid;
    wire                            m_axi_rready;
    reg [1:0]                       m_axi_rresp;
    //
    reg [31:0]                      start_addr;
    reg [31:0]                      bytes_to_read;
    reg                             start;
    wire                            done;
    //
    //AXI-Stream slave
    reg [M_AXI_DATA_WIDTH-1:0]      s_axis_tdata;
    reg [M_AXI_DATA_WIDTH/8-1:0]    s_axis_tkeep;
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
                .INTERFACE_TYPE     (INTERFACE_TYPE  ),

                .M_AXI_ADDR_WIDTH   (M_AXI_ADDR_WIDTH),
                .M_AXI_DATA_WIDTH   (M_AXI_DATA_WIDTH)
            ) top_frame_subtraction_inst
            (
                .clk                (clk          ),
                .resetn             (resetn       ),
    
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
    
    
                .m_axis_tdata       (m_axis_tdata ),
                .m_axis_tkeep       (m_axis_tkeep ),
                .m_axis_tlast       (m_axis_tlast ),
                .m_axis_tready      (m_axis_tready),
                .m_axis_tvalid      (m_axis_tvalid),
                .m_axis_tuser       (m_axis_tuser )
    
            );
        end
        else if (INTERFACE_TYPE == "AXI_STREAM") begin : gen_axis
            top_frame_subtraction #(
                .INTERFACE_TYPE  (INTERFACE_TYPE  ),
                .M_AXI_DATA_WIDTH(M_AXI_DATA_WIDTH)
                //.PIXEL_WIDTH    (PIXEL_WIDTH),
            ) top_frame_subtraction_inst
            (
                .clk            (clk          ),
                .resetn         (resetn       ),

                .s_axis_tdata   (s_axis_tdata ),
                .s_axis_tvalid  (s_axis_tvalid),
                .s_axis_tready  (s_axis_tready),
                .s_axis_tlast   (s_axis_tlast ),
                .s_axis_tkeep   (s_axis_tkeep ),
                .s_axis_tuser   (s_axis_tuser ),

                .width_frame    (width_frame  ),
                .height_frame   (height_frame ),

                .m_axis_tdata   (m_axis_tdata ),
                .m_axis_tkeep   (m_axis_tkeep ),
                .m_axis_tlast   (m_axis_tlast ),
                .m_axis_tready  (m_axis_tready),
                .m_axis_tvalid  (m_axis_tvalid),
                .m_axis_tuser   (m_axis_tuser )
            );
        end
    endgenerate

    integer beats_in_burst;
    integer start_word;
    //Tasks
    task axi_master_read_responder;
        input integer memory_size;
        input integer burst_len;

        integer mem_ptr;
        integer burst_cnt;
        integer beat_cnt;
        integer bytes_per_word;

        begin
            //Init
            mem_ptr        = 0;
            burst_cnt      = 0;
            beat_cnt       = 0;
            bytes_per_word = M_AXI_DATA_WIDTH / 8;

            $display("Memory size = %0d words", memory_size);

            while (1) begin
                @(posedge clk);

                //Wait arvalid
                while (!m_axi_arvalid) begin
                    @(posedge clk);
                end


                beats_in_burst = m_axi_arlen + 1;
                start_word = m_axi_araddr / bytes_per_word;

                $display("[%0t] AXI read request: addr=0x%0h, beats=%0d, start_word=%0d", 
                         $time, m_axi_araddr, beats_in_burst, start_word);

                //Set arredy
                @(posedge clk);
                m_axi_arready <= 1'b1;
                @(posedge clk);
                m_axi_arready <= 1'b0;

                //Transmit data
                for (beat_cnt = 0; beat_cnt < beats_in_burst; beat_cnt = beat_cnt + 1) begin
                    //In field memory
                    if (start_word + beat_cnt >= memory_size) begin
                        $display("ERROR: Read outside memory size");
                        $finish;
                    end

                    //wait rready
                    while (!m_axi_rready) begin
                        @(posedge clk);
                    end

                    //Transmit data
                    @(posedge clk);
                    m_axi_rvalid <= 1'b1;
                    m_axi_rdata  <= memory[start_word + beat_cnt];

                    //rlast = 1 last beat in last burst
                    if (beat_cnt == beats_in_burst - 1) begin
                        m_axi_rlast <= 1'b1;
                    end else begin
                        m_axi_rlast <= 1'b0;
                    end

                end
                //Wait, while master transmit data
                @(posedge clk);
                m_axi_rvalid <= 1'b0;
                m_axi_rlast  <= 1'b0;

                $display("[%0t] AXI read completed: %0d words", $time, beats_in_burst);

                if (done) begin
                    $display("done");

                end
            end
        end
    endtask

    //Memory
    localparam MEMORY_WORDS = 640 * 480 * 2;  // 2 frames into 1920x1080 pixel
    reg [M_AXI_DATA_WIDTH-1:0] memory [0:MEMORY_WORDS-1];

    //Fill memory
    task fill_memory;
        integer i;
        integer frame_offset;
        integer pixel_value;

        begin
            //Frame 1 (base_offset = 0)
            frame_offset = 0;
            for (i = 0; i < 640 * 480 / 16; i = i + 1) begin
                memory[frame_offset + i] = {
                    8'hF0 + (i % 16), 8'hE0 + (i % 16), 8'hD0 + (i % 16), 8'hC0 + (i % 16),
                    8'hB0 + (i % 16), 8'hA0 + (i % 16), 8'h90 + (i % 16), 8'h80 + (i % 16),
                    8'h70 + (i % 16), 8'h60 + (i % 16), 8'h50 + (i % 16), 8'h40 + (i % 16),
                    8'h30 + (i % 16), 8'h20 + (i % 16), 8'h10 + (i % 16), 8'h00 + (i % 16)
                };
            end

            //Frame 2 (base_offset = 64)
            frame_offset = 640 * 480 / 16;
            for (i = 0; i < 640 * 480 / 16; i = i + 1) begin
                memory[frame_offset + i] = {
                    8'hF0 + ((i + 64) % 256), 8'hE0 + ((i + 64) % 256), 8'hD0 + ((i + 64) % 256), 8'hC0 + ((i + 64) % 256),
                    8'hB0 + ((i + 64) % 256), 8'hA0 + ((i + 64) % 256), 8'h90 + ((i + 64) % 256), 8'h80 + ((i + 64) % 256),
                    8'h70 + ((i + 64) % 256), 8'h60 + ((i + 64) % 256), 8'h50 + ((i + 64) % 256), 8'h40 + ((i + 64) % 256),
                    8'h30 + ((i + 64) % 256), 8'h20 + ((i + 64) % 256), 8'h10 + ((i + 64) % 256), 8'h00 + ((i + 64) % 256)
                };
            end

            $display("Memory filled: %0d words", MEMORY_WORDS);
        end
    endtask

    task axi_stream_write_line;
        input integer line_num;
        input integer words_per_line;
        input integer base_offset;

        integer i;

        begin
            for (i = 0; i < words_per_line; i = i + 1) begin
                @(posedge clk);
                //Data
                s_axis_tdata <= {
                    8'h00 + ((i + base_offset) % 256),
                    8'h10 + ((i + base_offset + 1) % 256),
                    8'h20 + ((i + base_offset + 2) % 256),
                    8'h30 + ((i + base_offset + 3) % 256),
                    8'h40 + ((i + base_offset + 4) % 256),
                    8'h50 + ((i + base_offset + 5) % 256),
                    8'h60 + ((i + base_offset + 6) % 256),
                    8'h70 + ((i + base_offset + 7) % 256),
                    8'h80 + ((i + base_offset + 8) % 256),
                    8'h90 + ((i + base_offset + 9) % 256),
                    8'hA0 + ((i + base_offset + 10) % 256),
                    8'hB0 + ((i + base_offset + 11) % 256),
                    8'hC0 + ((i + base_offset + 12) % 256),
                    8'hD0 + ((i + base_offset + 13) % 256),
                    8'hE0 + ((i + base_offset + 14) % 256),
                    8'hF0 + ((i + base_offset + 15) % 256)
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

        width_frame  = 640;
        height_frame = 480;

        fill_memory();

        //AXI4-Full Master (MM2S)
        m_axi_arready  = 0;
        m_axi_rdata    = 0;
        m_axi_rlast    = 0;
        m_axi_rvalid   = 0;
        m_axi_rresp    = 0;

        start_addr     = 0;
        bytes_to_read  = 0;
        start          = 0;

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

            start_addr    <= 32'h0000_0000;
            bytes_to_read <= 640 * 480;
            start         <= 1'b1;

            axi_master_read_responder(MEMORY_WORDS, 0);  // 120 beats = строка

            //wait (done);
            $display("AXI Master finished.");
        

        end else if (INTERFACE_TYPE == "AXI_STREAM") begin
            for (i = 0; i < height_frame*2; i = i + 1) begin
                axi_stream_write_line(2, 120, i);
                axi_stream_write_line(2, 120, i+5);
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