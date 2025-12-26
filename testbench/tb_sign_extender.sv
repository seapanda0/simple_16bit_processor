`timescale 1ns/1ns

module tb_sign_extender();

    logic [8:0] in;
    logic [15:0] out, expected_out;

    logic [8:0] vectors [6:0];

    sign_extender uut (in, out);

    integer errors, i;

    initial begin
        errors = 0;
        vectors[0] = 9'h000;
        vectors[1] = 9'h100;
        vectors[2] = 9'h1FF;
        vectors[3] = 9'h07F;
        vectors[4] = 9'h08F;
        vectors[5] = 9'h1AE;
        vectors[6] = 9'h0FF;
        
        foreach (vectors[i]) begin
            in = vectors[i];
            #1;
            expected_out = {{7{in[8]}}, in};
            if (expected_out !== out) begin
                $display("[ERROR] IN : %h OUT : %h EXPEDTED : %h", in, out, expected_out);
                errors = errors + 1;
            end
            else $display("[OK] sign_extender - IN : %h OUT : %h", in, out);
        end
        if (errors == 0) $display("tb_sign_extender: ALL PASS");
        else $display("tb_sign_extender %d FAILURES", errors);
        #1 $finish;
    end

endmodule