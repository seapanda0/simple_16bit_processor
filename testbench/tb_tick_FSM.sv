`timescale 1ns/1ns
module tb_tick_FSM();

    localparam int TEST_VECTOR_LINES = 6;

    logic clk, rst, ena;
    logic [3:0] tick, expected_tick;
    logic [3:0] testvectors [TEST_VECTOR_LINES:0];
    integer vector_num = 0;
    
    tick_FSM uut(.clk(clk), .rst(rst), .ena(ena), .tick(tick));

    // Read testvector files
    initial begin
        integer i;
        $readmemb("testbench/tb_tick_FSM.tv", testvectors);
        $display("Contents of testvectors");
        for (i=0; i<= TEST_VECTOR_LINES; i = i + 1) begin
            $display("testvector[%0d] = %b", i, testvectors[i]);
        end
    end
    // Read testvector on every negative edge
    always @(negedge clk) begin
        expected_tick = testvectors[vector_num];
    end

    always @(posedge clk) begin
        #1;
        if (expected_tick !== tick) begin
            $display("Error! : Time %3d | expected_tick %4b | tick %4b", $time, expected_tick, tick);
        end
        // Check if next data is the end of the testvector
        vector_num = vector_num + 1;
        if (testvectors[vector_num] === 4'bxxxx) begin
            $display("Simulation completed");
            $finish;
        end
    end

    // Clock signal generator
    always begin
        clk = 0; #5; clk = 1; #5;
    end

    initial begin
        ena = 1;
        rst = 1; #7; rst = 0;
    end

    initial begin
        $monitor("Time %3d | expected_tick %4b | tick %4b", $time, expected_tick, tick);
    end
endmodule