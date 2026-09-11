//*****************************************************************//
// Company:      None                                              //
//                                                                 //
// Filename:     axif2buffer.v                                     //
// Version:      v1.0                                              //
// Library:      None                                              //
// Parent:       none                                              //
// Description:  AXI4-Full Master to read data from DDR to buffer. //
//                                                                 //
//               Please refer to the Product Guide for more        //
//               detailed information.                             //
// --------------------------------------------------------------- //
// Author(s):    M. Dumanski                                       //
//                                                                 //
// History:                                                        //
//    11.09.2026 - (v1.0) Initial version                          //
//                                                                 //
//*****************************************************************//
`timescale 1ns / 1ps
`default_nettype none

module axif2buffer #
(
    parameter S_AXI_ADDR_WIDTH = 32,
    parameter S_AXI_DATA_WIDTH = 128,
    parameter BURST_LEN        = 16  //Amount beats in burst
)
(
    //System signals
    input  wire clk,
    input  wire resetn,
    
    //AXI4-Full Master
    //Address channel
    output wire  [S_AXI_ADDR_WIDTH-1:0] m_axi_araddr,
    output wire  [1:0]                  m_axi_arburst,
    output wire  [3:0]                  m_axi_arcache,
    //output reg  [3:0]                   m_axi_arid,
    output wire  [7:0]                  m_axi_arlen,
    //output reg                          m_axi_arlock,
    output wire  [2:0]                  m_axi_arprot,
    input  wire                         m_axi_arready,
    output wire  [2:0]                  m_axi_arsize,
    output wire                         m_axi_arvalid,
    
    //Read channel
    input  wire [S_AXI_DATA_WIDTH-1:0]  m_axi_rdata,
    //input  wire [3:0]                   m_axi_rid,
    input  wire                         m_axi_rlast,
    input  wire                         m_axi_rvalid,
    output wire                         m_axi_rready,
    input  wire [1:0]                   m_axi_rresp,
    
    //GPIO
    input  wire [31:0]                  start_addr,      //Address in DDR, for read
    input  wire [31:0]                  width_frame,     //Size line
    input  wire [31:0]                  height_frame,
    input  wire                         start,           //Signal start
    output wire                         done,            //Signal finish
    
    //Output
    output wire [31:0]                  capture_width_frame,
    output wire [31:0]                  capture_height_frame,
    
    output wire                         buf_wr_en,
    output wire [S_AXI_DATA_WIDTH-1:0]  buf_wr_data,
    output wire [31:0]                  buf_wr_addr,
    output wire                         buf_wr_last,
    input  wire                         buf_wr_full
);

    //Localparameter
    localparam          BYTES_PER_WORD  = S_AXI_DATA_WIDTH / 8;
    localparam          BYTES_PER_BURST = BYTES_PER_WORD * BURST_LEN;
    localparam          SHIFT_TO_BEATS  = $clog2(S_AXI_DATA_WIDTH/8);

    localparam [2:0]    ARSIZE          = $clog2(S_AXI_DATA_WIDTH/8);
    localparam          ARBUST_INCR     = 2'b01;

    //State FSM
    localparam IDLE      = 5'b00001;
    localparam ADDR      = 5'b00010;
    localparam DATA      = 5'b00100;
    localparam WAIT_FULL = 5'b01000;
    localparam DONE      = 5'b10000;

    reg [4:0] state, next_state;

    //Register output
    reg [S_AXI_ADDR_WIDTH-1:0]  m_axi_araddr_reg;
    reg [1:0]                   m_axi_arburst_reg;
    reg [3:0]                   m_axi_arcache_reg;
    reg [7:0]                   m_axi_arlen_reg;
    reg [2:0]                   m_axi_arprot_reg;
    reg [2:0]                   m_axi_arsize_reg;
    reg                         m_axi_arvalid_reg;

    //Counters
    reg [31:0]                  bytes_remaining; //Remaining read byte
    reg [31:0]                  current_addr;    //Current address Текущий адрес чтения
    reg [7:0]                   beat_cnt;        //Counter beats in burst
    reg                         burst_done;      //Flag finish burst

    //Register output
    reg [31:0]                  capture_width_frame_reg;
    reg [31:0]                  capture_height_frame_reg;

    reg                         buf_wr_en_reg;
    reg [S_AXI_DATA_WIDTH-1:0]  buf_wr_data_reg;
    reg [31:0]                  buf_wr_addr_reg;
    reg                         buf_wr_last_reg;

    //FSM
    always @(posedge clk) begin
        if (!resetn) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start && !buf_wr_full) begin
                    next_state = ADDR;
                end
            end

            ADDR: begin
                //Wait, while memory receive address
                if (m_axi_arready && m_axi_arvalid) begin
                    next_state = DATA;
                end
            end

            DATA: begin
                //If last beat in burst
                if (m_axi_rvalid && m_axi_rready && m_axi_rlast) begin
                    if (bytes_remaining <= BYTES_PER_BURST) begin
                        next_state = DONE;
                    end else begin
                        next_state = ADDR;
                    end
                end
            end

            DONE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    //Address channel
    //assign m_axi_arvalid = (state == ADDR);
    always @(posedge clk) begin
        if (!resetn) begin
            m_axi_araddr_reg  <= {S_AXI_ADDR_WIDTH{1'b0}};
            m_axi_arlen_reg   <= 8'b0;
            m_axi_arsize_reg  <= 3'b0;
            m_axi_arburst_reg <= 2'b0;
            m_axi_arprot_reg  <= 3'b000;
            m_axi_arcache_reg <= 4'b0011;
            m_axi_arvalid_reg <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    //pass
                end

                ADDR: begin
                    //Parameters burst
                    m_axi_arvalid_reg <= (m_axi_arready && m_axi_arvalid) ? 1'b0 : 1'b1;
                    m_axi_arsize_reg  <= ARSIZE;        // 16 byte (2^4 = 16)
                    m_axi_arburst_reg <= ARBUST_INCR;   // INCR burst
                    m_axi_araddr_reg  <= current_addr;
                    if (bytes_remaining >= BYTES_PER_BURST) begin
                        m_axi_arlen_reg <= BURST_LEN - 1;  // len = beats - 1
                    end
                    else begin
                        m_axi_arlen_reg <= (bytes_remaining >> SHIFT_TO_BEATS) - 1;
                    end

                end

                DATA: begin
                    //pass
                end

                default: begin
                    //pass
                end
            endcase
        end
    end

    assign m_axi_rready = (state == DATA) && !buf_wr_full;
    //Read data channel
    always @(posedge clk) begin
        if (!resetn) begin
            beat_cnt   <= 8'b0;
            burst_done <= 1'b0;
        end else begin
            case (state)
                DATA: begin
                    if (m_axi_rvalid && m_axi_rready) begin

                        //Receive data
                        buf_wr_en_reg   <= 1'b1;
                        buf_wr_data_reg <= m_axi_rdata;
                        buf_wr_addr_reg <= current_addr; //not correct (no matter, because not use)

                        //If last beat
                        if (m_axi_rlast) begin
                            beat_cnt   <= 8'b0;
                            burst_done <= 1'b1;
                        end
                        else begin
                            beat_cnt   <= beat_cnt + 1;
                            burst_done <= 1'b0;
                        end
                    end
                    else begin
                        buf_wr_en_reg <= 1'b0;
                    end
                end

                default: begin
                    buf_wr_en_reg <= 1'b0;
                    beat_cnt      <= 8'b0;
                    burst_done    <= 1'b0;
                end
            endcase
        end
    end

    //Control address and counters
    always @(posedge clk) begin
        if (!resetn) begin
            current_addr    <= 32'h0000_0000;
            bytes_remaining <= 32'h0000_0000;

            capture_width_frame_reg  <= 32'h0000_0000;
            capture_height_frame_reg <= 32'h0000_0000;
        end else begin
            case (state)
                IDLE: begin
                    if (start && !buf_wr_full) begin
                        current_addr             <= start_addr;
                        bytes_remaining          <= width_frame;

                        capture_width_frame_reg  <= width_frame;
                        capture_height_frame_reg <= height_frame;
                    end
                end

                DATA: begin
                    if (m_axi_rvalid && m_axi_rready) begin
                        current_addr    <= current_addr + BYTES_PER_WORD;
                        bytes_remaining <= bytes_remaining - BYTES_PER_WORD;
                    end
                end

                DONE: begin
                    //pass
                end

                default: begin
                    //pass
                end
            endcase
        end
    end

    //buf_wr_last
    always @(posedge clk) begin
        if (!resetn) begin
            buf_wr_last_reg <= 1'b0;
        end else begin
            buf_wr_last_reg <= m_axi_rvalid                        &&
                               m_axi_rready                        &&
                               m_axi_rlast                         &&
                               (bytes_remaining <= BYTES_PER_WORD)  ? 1'b1 : 1'b0;
        end
    end

    //Signal finish
    reg done_reg;
    always @(posedge clk) begin
        if (!resetn) begin
            done_reg <= 1'b0;
        end
        else begin
            done_reg <= (state == DONE) ? 1'b1 : 1'b0;
        end
    end

    //Assigments
    assign m_axi_araddr         = m_axi_araddr_reg;
    assign m_axi_arburst        = m_axi_arburst_reg;
    assign m_axi_arcache        = m_axi_arcache_reg;
    assign m_axi_arlen          = m_axi_arlen_reg;
    assign m_axi_arprot         = m_axi_arprot_reg;
    assign m_axi_arsize         = m_axi_arsize_reg;
    assign m_axi_arvalid        = m_axi_arvalid_reg;

    assign capture_width_frame  = capture_width_frame_reg;
    assign capture_height_frame = capture_height_frame_reg;

    assign buf_wr_en            = buf_wr_en_reg;
    assign buf_wr_data          = buf_wr_data_reg;
    assign buf_wr_addr          = buf_wr_addr_reg;
    assign buf_wr_last          = buf_wr_last_reg;

    assign done                 = done_reg;

endmodule
`default_nettype wire