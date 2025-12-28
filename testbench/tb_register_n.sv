`timescale 1ns/1ns
module tb_register_n();
    localparam WIDTH = 16;

    logic clk, rst, r_in;
    logic [WIDTH-1:0] data_in, expected_q, q;

    register_n #(.n(WIDTH)) uut(
        .clk(clk),
        .rst(rst),
        .r_in(r_in),
        .data_in(data_in),
        .q(q)
    );

    always begin
        clk = '0; #5; clk = '1; #5;
    end

    initial begin
        rst = '1; r_in = '0; data_in = '0; expected_q = '0;

        @(negedge clk);
        // Check reset functionality
        if (q !== expected_q) $display("[ERROR] Register failed to reset");
        else $display("[OK] Register reset successfully");

        // Ready to load data
        rst = '0; r_in = '1;
        void'(std::randomize(data_in));
        expected_q = data_in;
        
        @(negedge clk)
        if (q !== expected_q) $display("[ERROR] Register failed to load din = %5d | q = %5d", data_in, q);
        else $display("[OK] Register loaded successfully q =  %d", q);

        // Change data_in without loading
        r_in = '0;
        void'(std::randomize(data_in));

        @(negedge clk)
        if (q !== expected_q) $display("[ERROR] Register failed to hold din = %5d | q = %5d", data_in, q);
        else $display("[OK] Register holded successfully q =  %d", q);

        rst = 1;
        expected_q = '0;

        @(negedge clk);
        // Check reset functionality
        if (q !== expected_q) $display("[ERROR] Register failed to reset");
        else $display("[OK] Register reset successfully");

        $finish;
    end
endmodule