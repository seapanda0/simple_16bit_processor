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
    logic [15:0] REG_WRITE_BUS; // Shared for reg0-7, A and H
    logic [15:0] REG_READ_BUS [7:0]; // For reg0-7
    logic [3:0] BUS_MUX_SEL;
    
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
    logic [7:0] r_in;

    genvar i;
    generate
        for (i = 0; i <= 7; i++) begin : reg_bank
            register_n #(16) REG_I(
                .clk(clk),
                .rst(rst),
                .r_in(r_in[i]),
                .data_in(REG_WRITE_BUS),
                .q(REG_READ_BUS[i])
            );
        end
    endgenerate

    logic r_in_H, r_in_G;
    logic [15:0] reg_G_in; 
    logic [15:0] reg_G_out;

    // Stores computational result
    register_n #(16) REG_G(
        .clk(clk),
        .rst(rst),
        .r_in(r_in_G),
        .data_in(reg_G_in),
        .q(reg_G_out)
    );

    // Used for display and output purpose
    logic [15:0] reg_H_out;
    register_n #(16) REG_H(
        .clk(clk),
        .rst(rst),
        .r_in(r_in_H),
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
        .reg_G(reg_G_out),
        .sel(BUS_MUX_SEL),
        .multiplex_out(REG_WRITE_BUS)
    );
    /*****************MULTIPLEXER END********************/

    always_ff @( posedge clk ) begin : control_unit
        case (tick)
            /* FETCH */
            4'b0001 : begin
                IR <= din;

                case (din[8:6])
                    DISP : begin
                        BUS_MUX_SEL <= din[5:3]; // Change bus to select the register to read from
                        r_in_H <= 1'b1; // Select H to be written
                    end
                    MOV_I : begin
                        BUS_MUX_SEL <= 4'd8; // Change bus to select din to read from
                        r_in[din[5:3]] <= 1'b1; //Select the register to be written
                    end
                    default: ;
                endcase
            end

            /* DECODE */
            4'b0010: begin
                case (IR[8:6])
                    DISP : begin

                    end
                    MOV_I: begin
                    end
                    default: ;
                endcase                
            end 
            
            4'b0100: begin
                case (IR[8:6])
                    DISP : begin
                        BUS_MUX_SEL <= 4'h0;
                        r_in_H <= 1'b0;
                    end
                    MOV_I : begin
                        BUS_MUX_SEL <= 4'h0;
                        r_in[IR[5:3]] <= 1'b0;
                    end
                    default: ;
                endcase   
            end
            4'b1000: begin
                case (IR[8:6])
                    DISP : ;
                    default: ;
                endcase 
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