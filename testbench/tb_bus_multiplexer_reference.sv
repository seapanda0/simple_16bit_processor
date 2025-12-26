`timescale 1ns/1ps
module tb_bus_multiplexer();
    logic [15:0] cpu_reg [7:0];
    logic [15:0] din_extended;
    logic [15:0] reg_G;
    logic [3:0] sel;
    logic [15:0] multiplex_out;

    bus_multiplexer uut(.cpu_reg(cpu_reg), .din_extended(din_extended), .reg_G(reg_G), .sel(sel), .multiplex_out(multiplex_out));

    int unsigned errors = 0;

    initial begin
        // initialize cpu_reg
        for (int i = 0; i < 8; i++) cpu_reg[i] = 16'h1000 + i;
        din_extended = 16'hABCD;
        reg_G = 16'hDEAD;

        // test sel 0..7
        for (int i = 0; i < 8; i++) begin
            sel = i;
            #1;
            if (multiplex_out !== cpu_reg[i]) begin
                $display("[FAIL] bus_mux sel=%0d out=%h expected=%h", i, multiplex_out, cpu_reg[i]);
                errors++;
            end else $display("[OK] bus_mux sel=%0d out=%h", i, multiplex_out);
        end

        // sel 8 -> din_extended
        sel = 4'd8; #1;
        if (multiplex_out !== din_extended) begin
            $display("[FAIL] bus_mux sel=8 out=%h expected=%h", multiplex_out, din_extended); errors++; end
        else $display("[OK] bus_mux sel=8 out=%h", multiplex_out);

        // sel 10 -> reg_G
        sel = 4'd10; #1;
        if (multiplex_out !== reg_G) begin
            $display("[FAIL] bus_mux sel=10 out=%h expected=%h", multiplex_out, reg_G); errors++; end
        else $display("[OK] bus_mux sel=10 out=%h", multiplex_out);

        // some default sel (e.g., 9 or 11) -> 0
        sel = 4'd9; #1;
        if (multiplex_out !== 16'd0) begin
            $display("[FAIL] bus_mux sel=9 out=%h expected=0", multiplex_out); errors++; end
        else $display("[OK] bus_mux sel=9 out=%h", multiplex_out);

        if (errors == 0) $display("tb_bus_multiplexer: ALL PASS");
        else $display("tb_bus_multiplexer: %0d FAILURES", errors);
        #1 $finish;
    end
endmodule
