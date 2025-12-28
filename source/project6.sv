/* INSTRUCTION TABLE */
/*
000 - DISP
001 - ADD
010 - ADD IMMEDIATE
011 - SUB
100 - MUL
101 - SRL
110 - SLL
111 - MOV IMMEDIATE
*/

module project6(
    input wire logic [8:0] SW,
    input wire logic [4:0] KEY,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [1:0] LEDR
);
    typedef enum logic [2:0] {
        DISP  = 3'b000,
        ADD   = 3'b001,
        ADD_I = 3'b010,
        SUB   = 3'b011,
        MUL   = 3'b100,
        SRL   = 3'b101,
        SLL   = 3'b110,
        MOV_I = 3'b111
    } opcode_t;

    typedef enum logic [2:0] {
        ALU_ADD = 3'b000,
        ALU_SUB = 3'b001,
        ALU_MUL = 3'b010,
        ALU_RR = 3'b011,
        ALU_RL = 3'b100
    }alu_op_t;

    // EXTERNAL CONNECTIONS
    // to be assigned to fpga pins
    logic clk, rst;
    logic [8:0] din;
    logic tick_ena;

    assign clk = KEY[0];
    assign rst = ~KEY[1];
    assign tick_ena = '1;
    assign din = SW;

    // PROCESSOR COMPONENTS
    logic [8:0] IR; // Instruction register

    // DATA BUSES
    logic [15:0] REG_WRITE_BUS; // Shared for reg0-7, A and H
    logic [15:0] REG_READ_BUS [7:0]; // For reg0-7
    logic [15:0] REG_G_WRITE_BUS; // Reg G stores output of ALU
    logic [15:0] REG_G_READ_BUS; // Reg G stores output of ALU
    logic [15:0] REG_A_READ_BUS; // Reg A connected to input of ALU

    // CONTROL SIGNALS
    logic [3:0] BUS_MUX_SEL;
    logic [7:0] REG_BANK_WRITE; // assert to write to reg 0-7
    logic REG_A_WRITE, REG_H_WRITE, REG_G_WRITE; // assert to write to G and H    
    // newly added
    logic [2:0] ALU_OP;
    
    /* TICK FSM */
    logic [3:0] tick;
    tick_FSM TICK_FSM_INST(
        .clk(clk),
        .rst(rst),
        .ena(tick_ena),
        .tick(tick)
    );

    /* SIGN EXTENDER */
    logic [15:0] din_extended;
    sign_extender SIGN_EXTD_INST(din, din_extended);

    /*******************REGISTERS START********************/
    // Generate 8 registers
    genvar i;
    generate
        for (i = 0; i <= 7; i++) begin : reg_bank
            register_n #(16) REG_I(
                .clk(clk),
                .rst(rst),
                .r_in(REG_BANK_WRITE[i]),
                .data_in(REG_WRITE_BUS),
                .q(REG_READ_BUS[i])
            );
        end
    endgenerate

    // Stores one of the inputs of ALU
    register_n #(16) REG_A(
        .clk(clk),
        .rst(rst),
        .r_in(REG_A_WRITE),
        .data_in(REG_WRITE_BUS),
        .q(REG_A_READ_BUS)
    );

    // Stores computational result
    register_n #(16) REG_G(
        .clk(clk),
        .rst(rst),
        .r_in(REG_G_WRITE),
        .data_in(REG_G_WRITE_BUS),
        .q(REG_G_READ_BUS)
    );

    // Used for display and output purpose
    logic [15:0] reg_H_out;
    register_n #(16) REG_H(
        .clk(clk),
        .rst(rst),
        .r_in(REG_H_WRITE),
        .data_in(REG_WRITE_BUS),
        .q(reg_H_out)
    );
    /*******************REGISTERS END********************/

    /*****************MULTIPLEXER START******************/
    /* Mux in: reg0-7_out, regG, d_in extended (10 inputs)  */
    /* Mux out: reg0-7_in, reg A, reg H (parallel 1 output) */
    
    bus_multiplexer BUS_MUX_INST (
        .cpu_reg(REG_READ_BUS),
        .din_extended(din_extended),
        .reg_G(REG_G_READ_BUS),
        .sel(BUS_MUX_SEL),
        .multiplex_out(REG_WRITE_BUS)
    );
    /*****************MULTIPLEXER END********************/

    /********************ALU START***********************/

    alu ALU_INST (
        .a(REG_A_READ_BUS),
        .b(REG_WRITE_BUS),
        .alu_op(ALU_OP),
        .result(REG_G_WRITE_BUS)
    );

    /********************ALU END*************************/

    always_ff @(posedge clk) begin
        if (rst) IR <= '0;
        else if (tick[0] == 1'b1) IR <= din;
    end

    always_comb begin : control_unit
        case (tick)

            /* FETCH */
            4'b0001 : begin
                BUS_MUX_SEL = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = 0; ALU_OP = '0;
            end

            /* DECODE */
            4'b0010 : begin
                case (IR[8:6])
                    DISP : begin
                       BUS_MUX_SEL = IR[5:3]; // Change bus to select the register to read from
                       REG_H_WRITE = 1'b1; // Select H to be written
                       REG_G_WRITE = '0; REG_BANK_WRITE = '0; REG_A_WRITE = '0; ALU_OP = '0;
                    end
                    MOV_I : begin
                        BUS_MUX_SEL = 4'd8; // Change bus to select din to read from
                        REG_BANK_WRITE = '0;
                        REG_BANK_WRITE[IR[5:3]] = 1'b1; //Select the register to be written
                        REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = '0; ALU_OP = '0;
                    end
                    ADD : begin
                        // Load first operand (Rx) to reg A
                        BUS_MUX_SEL = IR[5:3]; // Change bus to select the register (Rx) to read from
                        REG_A_WRITE = '1;
                        ALU_OP = ALU_ADD;
                        REG_G_WRITE = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; ALU_OP = '0;
                    end
                    default: begin
                        BUS_MUX_SEL = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = 0; ALU_OP = '0;
                    end
                endcase
            end

            /* EXECUTE */
            4'b0100 : begin
                case (IR[8:6])
                    DISP, MOV_I : begin
                        BUS_MUX_SEL = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = 0; ALU_OP = '0;
                    end
                    ADD : begin
                        BUS_MUX_SEL = IR[2:0]; // Change the input of the second operand of ALU to Ry
                        ALU_OP = ALU_ADD; // Set ALU_ADD control signal
                        REG_G_WRITE = '1; // Store result in register G
                        REG_A_WRITE = '0; REG_H_WRITE = '0; REG_BANK_WRITE = '0;
                    end
                    default : begin
                        BUS_MUX_SEL = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = 0; ALU_OP = '0;
                    end
                endcase
            end

            4'b1000 : begin
                case (IR[8:6])                    
                    DISP, MOV_I : begin
                        BUS_MUX_SEL = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = 0; ALU_OP = '0;
                    end
                    ADD : begin
                        // Rx = Rx + Ry
                        BUS_MUX_SEL = 4'd9; // Select reg G
                        REG_BANK_WRITE = '0;
                        REG_BANK_WRITE[IR[5:3]] = 1'b1; // Select RX as the register to write to
                        REG_A_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; ALU_OP = '0;
                    end
                    default : begin
                        BUS_MUX_SEL = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = 0; ALU_OP = '0;
                    end            
                endcase
            end
            default: begin
                BUS_MUX_SEL = '0; REG_BANK_WRITE = '0; REG_H_WRITE = '0; REG_G_WRITE = '0; REG_A_WRITE = 0; ALU_OP = '0;
            end
        endcase
    end

    /* IO Connections */
    binary_to_7seg h0 (reg_H_out[3:0], HEX0);
    binary_to_7seg h1 (reg_H_out[7:4], HEX1);
    binary_to_7seg h2 (reg_H_out[11:8], HEX2);
    binary_to_7seg h3 (reg_H_out[15:12], HEX3);

    fsm_tick_to_7seg h4 (tick, HEX4);
endmodule