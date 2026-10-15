`timescale 1ns/1ps

module micro_dma (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [31:0] base_addr,
    input  logic [15:0] length_words,
    output logic        busy,
    output logic        done,
    output logic        config_error,
    output logic        mem_req_valid,
    input  logic        mem_req_ready,
    output logic [31:0] mem_req_addr,
    input  logic        mem_rsp_valid,
    input  logic [31:0] mem_rsp_data,
    output logic        out_valid,
    input  logic        out_ready,
    output logic [31:0] out_data,
    output logic        out_last
);
    typedef enum logic [1:0] {IDLE, ISSUE, WAIT_RSP, SEND} state_t;
    state_t state;
    logic [31:0] address_q;
    logic [15:0] remaining_q;
    logic [31:0] data_q;

    assign busy = (state != IDLE);
    assign mem_req_valid = (state == ISSUE);
    assign mem_req_addr = address_q;
    assign out_valid = (state == SEND);
    assign out_data = data_q;
    assign out_last = (state == SEND) && (remaining_q == 16'd1);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            address_q <= '0;
            remaining_q <= '0;
            data_q <= '0;
            done <= 1'b0;
            config_error <= 1'b0;
        end else begin
            done <= 1'b0;
            config_error <= 1'b0;
            unique case (state)
                IDLE: begin
                    if (start) begin
                        if ((length_words == 0) || (base_addr[1:0] != 2'b00)) begin
                            config_error <= 1'b1;
                        end else begin
                            address_q <= base_addr;
                            remaining_q <= length_words;
                            state <= ISSUE;
                        end
                    end
                end
                ISSUE: begin
                    if (mem_req_valid && mem_req_ready)
                        state <= WAIT_RSP;
                end
                WAIT_RSP: begin
                    if (mem_rsp_valid) begin
                        data_q <= mem_rsp_data;
                        state <= SEND;
                    end
                end
                SEND: begin
                    if (out_valid && out_ready) begin
                        if (remaining_q == 16'd1) begin
                            remaining_q <= '0;
                            done <= 1'b1;
                            state <= IDLE;
                        end else begin
                            remaining_q <= remaining_q - 1'b1;
                            address_q <= address_q + 32'd4;
                            state <= ISSUE;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
