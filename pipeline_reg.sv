module pipeline_reg #(parameter DATA_WIDTH = 32)(
    input  logic clk,
    input  logic rst_n,

    // input interface
    input  logic [DATA_WIDTH-1:0]  in_data,
    input  logic in_valid,
    output logic in_ready,

    // output interface
    output logic [DATA_WIDTH-1:0]  out_data,
    output logic out_valid,
    input  logic out_ready
);

    logic [DATA_WIDTH-1:0] data_reg;
    logic valid_reg;

    // ready when empty or when current data is being accepted by output
    assign in_ready  = ~valid_reg || out_ready;

    // output signals
    assign out_data  = data_reg;
    assign out_valid = valid_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_reg <= 1'b0;   // empty on reset
        end else begin
            // case 1: input handshake happens
            if (in_valid && in_ready) begin
                data_reg  <= in_data;
                valid_reg <= 1'b1;
            end
            // case 2: output handshake without new input
            else if (out_ready && out_valid) begin
                valid_reg <= 1'b0;
            end
        end
    end

endmodule

