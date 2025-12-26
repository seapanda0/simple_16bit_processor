`timescale 1ns/1ns
module tb_alu();
    typedef enum logic [2:0] {
        ALU_ADD = 3'b000,
        ALU_SUB = 3'b001,
        ALU_MUL = 3'b010,
        ALU_RR = 3'b011,
        ALU_RL = 3'b100
    }alu_op_t;
    
    logic [15:0] a, b;
    logic [15:0] alu_out, expected_alu_out;
    logic [2:0] alu_op;

    alu uut(.a(a), .b(b), .alu_op(alu_op), .result(alu_out));
    
    integer i, j, errors;

    initial begin
        logic [15:0] vecA [3:0];
        logic [15:0] vecB [3:0];
        vecA[0] = 16'h0000; vecB[0] = 16'h0001;
        vecA[1] = 16'h000A; vecB[1] = 16'h0002;
        vecA[2] = 16'h957C; vecB[2] = 16'hDE63;
        vecA[3] = 16'h65FA; vecB[3] = 16'hF13F;
        errors = 0;
        foreach (vecA[i]) begin
            a = vecA[i]; b = vecB[i];
            for (alu_op = '0; alu_op <= ALU_RL; alu_op++) begin
                // Compute our expected result
                case (alu_op)
                    ALU_ADD : expected_alu_out = vecA[i] + vecB[i];
                    ALU_SUB : expected_alu_out = vecA[i] - vecB[i];
                    ALU_MUL : expected_alu_out = vecA[i] * vecB[i];
                    ALU_RR : expected_alu_out = vecB[i] >> 1 ;
                    ALU_RL : expected_alu_out = vecB[i] << 1;
                    default: expected_alu_out = '0;
                endcase
                
                #1; // Send the signal to uut
             
                // Compare the results
                if (expected_alu_out === alu_out) $display("[OK] %4h %4h %2h %4h", a, b, alu_op, alu_out);
                else begin
                    errors++;
                    $display("[ERROR] %4h %4h %2h %4h", a, b, alu_op, alu_out);
                end
            end
        end
        if (errors == 0) $display("[PASS] tb_alu");
        else $display("[FAILED] tb_alu failed with %3d errors", errors);
        $finish;
    end
endmodule
