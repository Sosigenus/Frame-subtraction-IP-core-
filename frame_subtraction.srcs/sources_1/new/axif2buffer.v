//*****************************************************************//
// Company:      None                                              //
//                                                                 //
// Filename:     axif2buffer.v                                     //
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
module axif2buffer #
(
    parameter S_AXI_ADDR_WIDTH = 32,
    parameter S_AXI_DATA_WIDTH = 128      
)
(
    //System signals
    input  wire clk,
    input  wire resetn,
    
    //AXI4-Full slave
    //Address write channel
    input  wire [S_AXI_ADDR_WIDTH-1:0]      s_axi_awaddr,
    input  wire [2:0]                       s_axi_awprot,
    input  wire                             s_axi_awvalid,
    output wire                             s_axi_awready,
    
    //Write data channel
    input  wire [S_AXI_DATA_WIDTH-1:0]      s_axi_wdata,
    input  wire [S_AXI_DATA_WIDTH/8-1:0]    s_axi_wstrb,
    input  wire                             s_axi_wvalid,
    output wire                             s_axi_wready,
    input  wire                             s_axi_wlast,
    
    //Write response channel
    output wire [1:0]                       s_axi_bresp,
    output wire                             s_axi_bvalid,
    input  wire                             s_axi_bready,
    
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
    reg [31:0]                  buf_wr_addr_reg;
    reg                         buf_wr_last_reg;

    //State FSM
    localparam IDLE     = 4'b0001;
    localparam ADDR     = 4'b0010;
    localparam DATA     = 4'b0100;
    localparam RESP     = 4'b1000;

    reg [3:0] state, next_state;

    //Current address
    reg [S_AXI_ADDR_WIDTH-1:0]  current_addr;
    reg                         addr_valid;  

    //Logic FSM
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
                //Wait request to write
                if (s_axi_awvalid) next_state = ADDR;
            end
            
            ADDR: begin
                //Wait, while address_ready valid
                if (s_axi_awready) next_state = DATA;
            end
            
            DATA: begin
                //Receive data, while WLAST = 0
                if (s_axi_wvalid && s_axi_wready && s_axi_wlast) begin
                    if (buf_wr_full) next_state = DATA; //Wait for buffer empty
                    else next_state = RESP;
                end
            end
            
            RESP: begin
                //Send answer
                if (s_axi_bvalid && s_axi_bready) next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    //Output AXI4 signals
    //Address channel
    assign s_axi_awready = (state == ADDR);

    //Write data channel
    assign s_axi_wready = (state == DATA) && !buf_wr_full;

    //Write response channel
    reg bvalid_reg;
    always @(posedge clk) begin
        if (!resetn) begin
            bvalid_reg <= 1'b0;
        end else if (state == RESP) begin
            bvalid_reg <= 1'b1;
        end else if (s_axi_bready) begin
            bvalid_reg <= 1'b0;
        end
    end

    assign s_axi_bvalid = bvalid_reg;
    assign s_axi_bresp  = 2'b00;  // OKAY

    //Capture address
    always @(posedge clk) begin
        if (!resetn) begin
            current_addr <= 0;
        end else if (s_axi_awvalid && s_axi_awready) begin
            current_addr <= s_axi_awaddr;
        end
    end

    //Output signals to buffer
    always @(posedge clk) begin
        if (!resetn) begin
            buf_wr_en_reg   <= 1'b0;
            buf_wr_data_reg <= 0;
            buf_wr_addr_reg <= 32'h0000_0000;
            buf_wr_last_reg <= 1'b0;
        end else if (state == DATA && s_axi_wvalid && s_axi_wready && !buf_wr_full) begin
            //Handshake
            buf_wr_en_reg   <= 1'b1;
            buf_wr_data_reg <= s_axi_wdata;
            buf_wr_addr_reg <= current_addr;
            buf_wr_last_reg <= s_axi_wlast;
        end else begin
            buf_wr_en_reg   <= 1'b0;
            buf_wr_last_reg <= 1'b0;
        end
    end

    //Assignments
    assign buf_wr_en    = buf_wr_en_reg;
    assign buf_wr_data  = buf_wr_data_reg;
    assign buf_wr_addr  = buf_wr_addr_reg;
    assign buf_wr_last  = buf_wr_last_reg;

endmodule
`default_nettype wire