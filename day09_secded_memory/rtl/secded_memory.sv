`timescale 1ns/1ps

module secded_memory #(
    parameter int DEPTH = 16,
    parameter int ADDR_WIDTH = $clog2(DEPTH)
) (
    input  logic                  clk,
    input  logic                  reset_n,
    input  logic                  req_valid,
    input  logic                  req_write,
    input  logic [ADDR_WIDTH-1:0] req_addr,
    input  logic [31:0]           req_wdata,
    output logic                  rsp_valid,
    output logic [31:0]           rsp_rdata,
    output logic                  single_error,
    output logic                  double_error,
    input  logic                  inject_valid,
    input  logic [ADDR_WIDTH-1:0] inject_addr,
    input  logic [38:0]           inject_mask
);
    logic [38:0] memory [0:DEPTH-1];

    function automatic bit is_parity_position(input int position);
        return (position == 1) || (position == 2) || (position == 4) ||
               (position == 8) || (position == 16) || (position == 32);
    endfunction

    function automatic logic [38:0] encode(input logic [31:0] data);
        logic [37:0] hamming;
        int data_index;
        logic parity;
        begin
            hamming = '0;
            data_index = 0;
            for (int position = 1; position <= 38; position++) begin
                if (!is_parity_position(position)) begin
                    hamming[position-1] = data[data_index];
                    data_index++;
                end
            end
            for (int p = 0; p < 6; p++) begin
                parity = 1'b0;
                for (int position = 1; position <= 38; position++)
                    if ((position & (1 << p)) != 0)
                        parity ^= hamming[position-1];
                hamming[(1 << p)-1] = parity;
            end
            encode[37:0] = hamming;
            encode[38] = ^hamming;
        end
    endfunction

    logic [38:0] selected_code;
    logic [37:0] corrected_hamming;
    logic [5:0] syndrome;
    logic overall_mismatch;
    logic [31:0] decoded_data;
    logic decode_single, decode_double;

    always_comb begin
        selected_code = memory[req_addr];
        syndrome = '0;
        for (int p = 0; p < 6; p++) begin
            for (int position = 1; position <= 38; position++)
                if ((position & (1 << p)) != 0)
                    syndrome[p] ^= selected_code[position-1];
        end
        overall_mismatch = ^selected_code;
        corrected_hamming = selected_code[37:0];
        decode_single = 1'b0;
        decode_double = 1'b0;
        if ((syndrome != 0) && overall_mismatch) begin
            decode_single = 1'b1;
            if (syndrome <= 38)
                corrected_hamming[syndrome-1] = ~corrected_hamming[syndrome-1];
        end else if ((syndrome == 0) && overall_mismatch) begin
            decode_single = 1'b1; // overall parity bit only
        end else if ((syndrome != 0) && !overall_mismatch) begin
            decode_double = 1'b1;
        end

        decoded_data = '0;
        begin : decode_payload
            int data_index;
            data_index = 0;
            for (int position = 1; position <= 38; position++) begin
                if (!is_parity_position(position)) begin
                    decoded_data[data_index] = corrected_hamming[position-1];
                    data_index++;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rsp_valid <= 1'b0;
            rsp_rdata <= '0;
            single_error <= 1'b0;
            double_error <= 1'b0;
            // Storage is intentionally not reset. Real SRAM macros generally do not
            // provide a bulk reset, and every address is written before use here.
        end else begin
            rsp_valid <= 1'b0;
            single_error <= 1'b0;
            double_error <= 1'b0;
            if (inject_valid)
                memory[inject_addr] <= memory[inject_addr] ^ inject_mask;
            if (req_valid) begin
                if (req_write) begin
                    memory[req_addr] <= encode(req_wdata);
                end else begin
                    rsp_valid <= 1'b1;
                    rsp_rdata <= decoded_data;
                    single_error <= decode_single;
                    double_error <= decode_double;
                end
            end
        end
    end
endmodule
