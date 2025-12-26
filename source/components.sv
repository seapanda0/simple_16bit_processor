module sign_extender(
    input wire logic [8:0] in,
    output logic [15:0] ext
);
    assign ext[8:0] = in;
    assign ext[15:9] = in[8] ? 7'b1111111 : 7'b0000000;

endmodule

module tick_FSM(
    input wire logic clk, rst, ena,
    output logic [3:0] tick
);

    always_ff @( posedge clk ) begin
        if (rst) tick <= 4'b0001;
        else if (ena) begin
            tick <= {tick[2:0], tick[3]};
        end
    end
endmodule

module alu(
    input wire logic [15:0] a, b,
    input wire logic [2:0] alu_op,
    output logic [15:0] result
);
    typedef enum logic [2:0] {
        ALU_ADD = 3'b000,
        ALU_SUB = 3'b001,
        ALU_MUL = 3'b010,
        ALU_RR = 3'b011,
        ALU_RL = 3'b100
    }alu_op_t;

    alu_op_t op;

    always_comb begin
        op = alu_op_t'(alu_op);
        unique case (op)
            ALU_ADD : result = a + b;
            ALU_SUB : result = a - b;
            ALU_MUL : result = a * b;
            ALU_RR : result = b >> 1;
            ALU_RL : result = b << 1;
            default: result = 16'b0;
        endcase
    end
endmodule

module bus_multiplexer(
    input wire logic [15:0] cpu_reg [7:0],
    input wire logic [15:0] din_extended,
    input wire logic [15:0] reg_G,
    input wire logic [3:0] sel,
    output logic [15:0] multiplex_out
);
    always_comb begin
        case (sel)
            4'd0: multiplex_out = cpu_reg[0];
            4'd1: multiplex_out = cpu_reg[1];
            4'd2: multiplex_out = cpu_reg[2];
            4'd3: multiplex_out = cpu_reg[3];
            4'd4: multiplex_out = cpu_reg[4];
            4'd5: multiplex_out = cpu_reg[5];
            4'd6: multiplex_out = cpu_reg[6];
            4'd7: multiplex_out = cpu_reg[7];
            4'd8: multiplex_out = din_extended;
            4'd10: multiplex_out = reg_G;
            default: multiplex_out = 16'd0;
        endcase
        
    end
endmodule

module register_n #(parameter n = 16)(
    input wire logic clk, rst, r_in,
    input wire logic [n-1:0] data_in,
    output logic [n-1:0] q
);
    always_ff @( posedge clk ) begin
        if (rst) q <= {n{1'd0}};
        else if (r_in) begin
            q <= data_in;
        end
        else q <= q;
    end
endmodule