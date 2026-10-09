module command_controller #(
    parameter int unsigned TIMEOUT_CYCLES = 8
) (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic request_valid,
    input  logic request_ready,
    input  logic response_valid,
    input  logic response_error,
    output logic busy,
    output logic done,
    output logic error
);
    localparam int unsigned COUNT_WIDTH =
        (TIMEOUT_CYCLES <= 1) ? 1 : $clog2(TIMEOUT_CYCLES);
    localparam logic [COUNT_WIDTH-1:0] TIMEOUT_LAST =
        COUNT_WIDTH'(TIMEOUT_CYCLES - 1);

    typedef enum logic [2:0] {
        IDLE, SEND, WAIT_RSP, COMPLETE, ERROR_STATE
    } state_t;

    state_t state, next_state;
    logic [COUNT_WIDTH-1:0] wait_count;
    logic timeout_hit;

    assign timeout_hit = (wait_count >= TIMEOUT_LAST);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            wait_count <= '0;
        end else begin
            state <= next_state;
            if (state != WAIT_RSP || response_valid)
                wait_count <= '0;
            else if (!timeout_hit)
                wait_count <= wait_count + 1'b1;
        end
    end

    always_comb begin
        next_state    = state;
        request_valid = 1'b0;
        busy          = 1'b0;
        done          = 1'b0;
        error         = 1'b0;
        case (state)
            IDLE: if (start) next_state = SEND;
            SEND: begin
                request_valid = 1'b1;
                busy = 1'b1;
                if (request_ready) next_state = WAIT_RSP;
            end
            WAIT_RSP: begin
                busy = 1'b1;
                if (response_valid)
                    next_state = response_error ? ERROR_STATE : COMPLETE;
                else if (timeout_hit)
                    next_state = ERROR_STATE;
            end
            COMPLETE: begin
                done = 1'b1;
                next_state = IDLE;
            end
            ERROR_STATE: begin
                error = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
endmodule
