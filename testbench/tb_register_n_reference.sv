`timescale 1ns/1ps
module tb_register_n();
    parameter N = 8;
    logic clk = 0;
    logic rst;
    logic r_in;
    logic [N-1:0] data_in;
    logic [N-1:0] q;

    // instantiate parameterized register
    register_n #(.n(N)) uut(.clk(clk), .rst(rst), .r_in(r_in), .data_in(data_in), .q(q));

    always #5 clk = ~clk;

    initial begin
        int unsigned errors = 0;

        // reset
        rst = 1; r_in = 0; data_in = 'h00;
        #12;
        if (q !== 'h00) begin $display("[FAIL] register_n: q not zero after reset (q=%h)", q); errors++; end
        else $display("[OK] register_n: reset clears q");

        rst = 0;
        // load a value with r_in = 1
        data_in = 8'hA5; r_in = 1;
        @(posedge clk); #1;
        if (q !== data_in) begin $display("[FAIL] register_n: did not capture when r_in=1 q=%h expected=%h", q, data_in); errors++; end
        else $display("[OK] register_n: captured value %h", q);

        // change data_in while r_in=0, q should hold
        r_in = 0; data_in = 8'h3C;
        @(posedge clk); #1;
        if (q !== 8'hA5) begin $display("[FAIL] register_n: q changed when r_in=0 q=%h expected=%h", q, 8'hA5); errors++; end
        else $display("[OK] register_n: held value %h", q);

        // synchronous reset again
        rst = 1; @(posedge clk); #1;
        if (q !== 'h00) begin $display("[FAIL] register_n: q not zero after second reset q=%h", q); errors++; end
        else $display("[OK] register_n: reset clears q (2)");

        if (errors == 0) $display("tb_register_n: ALL PASS");
        else $display("tb_register_n: %0d FAILURES", errors);
        #5 $finish;
    end
endmodule
