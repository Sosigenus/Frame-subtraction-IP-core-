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
    input  wire                    buf_wr_en,
    input  wire [DATA_WIDTH-1:0]   buf_wr_data,
    input  wire [31:0]             buf_wr_addr,
    input  wire                    buf_wr_last,
    output wire                    buf_wr_full,
    
    //Output signals to processing
    output wire [DATA_WIDTH-1:0]   rd_data_a,
    output wire [DATA_WIDTH-1:0]   rd_data_b,
    output wire                    rd_valid,
    output wire                    rd_last,
    output wire                    rd_user,
    input  wire                    rd_ready
);

    //Parameters
    localparam WORDS_PER_LINE = WIDTH_FRAME / (DATA_WIDTH / 8);
    localparam PTR_WIDTH      = $clog2(WORDS_PER_LINE);
    localparam ROWS_WIDTH     = $clog2(HEIGHT_FRAME);

    //State FSM
    localparam BUF_PING_A = 4'b0001;
    localparam BUF_PING_B = 4'b0010;
    localparam BUF_PONG_A = 4'b0100;
    localparam BUF_PONG_B = 4'b1000;
    reg [3:0] buf_state;

    //BRAM
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] bufferA_ping [0:15360-1];
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] bufferA_pong [0:15360-1];
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] bufferB_ping [0:15360-1];
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] bufferB_pong [0:15360-1];

    //Pointer write
    reg [PTR_WIDTH-1:0] ptr_wr_a_ping;
    reg [PTR_WIDTH-1:0] ptr_wr_b_ping;
    reg [PTR_WIDTH-1:0] ptr_wr_a_pong;
    reg [PTR_WIDTH-1:0] ptr_wr_b_pong;

    //Ready buffers
    reg ready_ping;
    reg ready_pong;
    
    reg buf_wr_full_reg;
    reg [PTR_WIDTH-1:0] ptr_buf_rd;

    //Write enable ping/pong
    wire we_a_ping;
    wire we_a_pong;
    wire we_b_ping;
    wire we_b_pong;

    //Address for bram
    wire [PTR_WIDTH-1:0] waddr_a_ping;
    wire [PTR_WIDTH-1:0] waddr_a_pong;
    wire [PTR_WIDTH-1:0] waddr_b_ping;
    wire [PTR_WIDTH-1:0] waddr_b_pong;

    //Write enable assigment
    assign we_a_ping = buf_wr_en && !buf_wr_full_reg && (buf_state == BUF_PING_A);
    assign we_b_ping = buf_wr_en && !buf_wr_full_reg && (buf_state == BUF_PING_B);
    assign we_a_pong = buf_wr_en && !buf_wr_full_reg && (buf_state == BUF_PONG_A);
    assign we_b_pong = buf_wr_en && !buf_wr_full_reg && (buf_state == BUF_PONG_B);

    assign waddr_a_ping = ptr_wr_a_ping;
    assign waddr_b_ping = ptr_wr_b_ping;
    assign waddr_a_pong = ptr_wr_a_pong;
    assign waddr_b_pong = ptr_wr_b_pong;

    //Register temp read from BRAM
    reg [DATA_WIDTH-1:0] rd_a_ping, rd_b_ping;
    reg [DATA_WIDTH-1:0] rd_a_pong, rd_b_pong;

    //Register output
    reg [DATA_WIDTH-1:0] rd_data_a_reg;
    reg [DATA_WIDTH-1:0] rd_data_b_reg;
    reg rd_valid_reg;
    reg rd_user_reg;

    //Counter rows
    reg [ROWS_WIDTH:0] counter_rows;

    //Synth BRAM
    always @(posedge clk) begin
        if (we_a_ping)
            bufferA_ping[waddr_a_ping] <= buf_wr_data;
        rd_a_ping <= bufferA_ping[ptr_buf_rd];

        if (we_b_ping)
            bufferB_ping[waddr_b_ping] <= buf_wr_data;
        rd_b_ping <= bufferB_ping[ptr_buf_rd];

        if (we_a_pong)
            bufferA_pong[waddr_a_pong] <= buf_wr_data;
        rd_a_pong <= bufferA_pong[ptr_buf_rd];

        if (we_b_pong)
            bufferB_pong[waddr_b_pong] <= buf_wr_data;
        rd_b_pong <= bufferB_pong[ptr_buf_rd];
    end

    //Control write/read pointers
    always @(posedge clk) begin
        if (!resetn) begin
            ptr_wr_a_ping   <= {PTR_WIDTH{1'b0}};
            ptr_wr_b_ping   <= {PTR_WIDTH{1'b0}};
            ptr_wr_a_pong   <= {PTR_WIDTH{1'b0}};
            ptr_wr_b_pong   <= {PTR_WIDTH{1'b0}};
            buf_state       <= BUF_PING_A;
            ready_ping      <= 1'b0;
            ready_pong      <= 1'b0;

            rd_data_a_reg <= {DATA_WIDTH{1'b0}};
            rd_data_b_reg <= {DATA_WIDTH{1'b0}};
            rd_valid_reg  <= 1'b0;
            rd_user_reg   <= 1'b0;
            ptr_buf_rd    <= {PTR_WIDTH{1'b0}};

        end else begin
            //Control write pointers
            if (buf_wr_en && !buf_wr_full_reg) begin
                case (buf_state)
                    BUF_PING_A: begin // Frame 1, Ping
                        if (ptr_wr_a_ping == WORDS_PER_LINE - 1) begin
                            ptr_wr_a_ping <= 0;
                            buf_state     <= BUF_PING_B;
                        end else begin
                            ptr_wr_a_ping <= ptr_wr_a_ping + 1;
                        end
                    end

                    BUF_PING_B: begin // Frame 2, Ping
                        if (ptr_wr_b_ping == WORDS_PER_LINE - 1) begin
                            ptr_wr_b_ping <= 0;
                            ready_ping    <= 1'b1;
                            buf_state     <= BUF_PONG_A;
                        end else begin
                            ptr_wr_b_ping <= ptr_wr_b_ping + 1;
                        end
                    end

                    BUF_PONG_A: begin // Frame 1, Pong
                        if (ptr_wr_a_pong == WORDS_PER_LINE - 1) begin
                            ptr_wr_a_pong <= 0;
                            buf_state     <= BUF_PONG_B;
                        end else begin
                            ptr_wr_a_pong <= ptr_wr_a_pong + 1;
                        end
                    end

                    BUF_PONG_B: begin // Frame 2, Pong
                        if (ptr_wr_b_pong == WORDS_PER_LINE - 1) begin
                            ptr_wr_b_pong <= 0;
                            ready_pong    <= 1'b1;
                            buf_state     <= BUF_PING_A;
                        end else begin
                            ptr_wr_b_pong <= ptr_wr_b_pong + 1;
                        end
                    end
                endcase
            end

            //Control read pointers
            if (rd_ready) begin
                if (ready_ping) begin
                    rd_data_a_reg <= rd_a_ping;
                    rd_data_b_reg <= rd_b_ping;
                    rd_valid_reg  <= 1'b1;
                    rd_user_reg   <= ptr_buf_rd == {PTR_WIDTH{1'b0}} ? 1'b1 : 1'b0;

                    if (ptr_buf_rd == WORDS_PER_LINE - 1) begin
                        ptr_buf_rd <= 0;
                        ready_ping <= 1'b0;
                    end else begin
                        ptr_buf_rd <= ptr_buf_rd + 1;
                    end
                end else if (ready_pong) begin
                    rd_data_a_reg <= rd_a_pong;
                    rd_data_b_reg <= rd_b_pong;
                    rd_valid_reg  <= 1'b1;
                    rd_user_reg   <= ptr_buf_rd == {PTR_WIDTH{1'b0}} ? 1'b1 : 1'b0;

                    if (ptr_buf_rd == WORDS_PER_LINE - 1) begin
                        ptr_buf_rd <= 0;
                        ready_pong <= 1'b0;
                    end else begin
                        ptr_buf_rd <= ptr_buf_rd + 1;
                    end
                end else begin
                    rd_valid_reg <= 1'b0;
                    rd_user_reg  <= 1'b0;
                end
            end else begin
                rd_valid_reg <= 1'b0;
                rd_user_reg  <= 1'b0;
            end
        end
    end

    //Full buffers
    always @(posedge clk) begin
        if (!resetn) begin
            buf_wr_full_reg <= 1'b0;
        end
        else begin
            //Full buffers
            buf_wr_full_reg <= (ready_ping && ready_pong) ? 1'b1 : 1'b0;
        end
    end

    //Counter rows
    always @(posedge clk) begin
        if (!resetn) begin
            counter_rows <= {ROWS_WIDTH{1'b0}};
        end
        else begin
            if (HEIGHT_FRAME == counter_rows) begin
                counter_rows <= {ROWS_WIDTH{1'b0}};
            end
            else if (rd_last) begin
                counter_rows <= counter_rows + 1;
            end
        end
    end

    //Assigments
    assign rd_data_a   = rd_data_a_reg;
    assign rd_data_b   = rd_data_b_reg;
    assign rd_valid    = rd_valid_reg && (ready_ping || ready_pong);
    assign rd_last     = (ptr_buf_rd == WORDS_PER_LINE - 1);
    assign rd_user     = rd_user_reg && (counter_rows == {ROWS_WIDTH{1'b0}});
    assign buf_wr_full = buf_wr_full_reg;

endmodule
`default_nettype wire