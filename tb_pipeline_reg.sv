`timescale 1ns/1ps

module tb_pipeline_reg;

    parameter DATA_WIDTH = 32;

    logic clk;
    logic rst_n;

    logic [DATA_WIDTH-1:0] in_data;
    logic in_valid;
    logic in_ready;

    logic [DATA_WIDTH-1:0] out_data;
    logic out_valid;
    logic out_ready;

    // DUT instantiation
  pipeline_reg #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_data(in_data),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .out_data(out_data),
        .out_valid(out_valid),
        .out_ready(out_ready)
    );

    always #5 clk = ~clk;

    initial begin

        clk       = 0;
        rst_n     = 0;
        in_data   = 0;
        in_valid  = 0;
        out_ready = 0;

        // Apply reset
        #20;
        rst_n = 1;

        // Test 1: Simple data transfer
        @(posedge clk);
        in_data  = 32'hA5A5_0001;
        in_valid = 1;
        out_ready = 1;

        @(posedge clk);
        in_valid = 0;

        // Test 2: Backpressure
        @(posedge clk);
        in_data  = 32'hA5A5_0002;
        in_valid = 1;
        out_ready = 0; 
        repeat (2) @(posedge clk);

        // Release backpressure
        out_ready = 1;

        @(posedge clk);
        in_valid = 0;

        // Test 3: Back-to-back transfers
        @(posedge clk);
        in_data  = 32'hA5A5_0003;
        in_valid = 1;

        @(posedge clk);
        in_data  = 32'hA5A5_0004;
        in_valid = 1;

        @(posedge clk);
        in_valid = 0;

        // Let simulation run
        repeat (5) @(posedge clk);

        $finish;
    end

    initial begin
        $display("Time\tin_v in_r in_data\tout_v out_r out_data");
        $monitor("%0t\t%b    %b    %h\t%b     %b     %h",
                 $time, in_valid, in_ready, in_data,
                 out_valid, out_ready, out_data);
    end

endmodule
