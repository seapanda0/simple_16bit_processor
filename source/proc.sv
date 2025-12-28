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

)
    logic clk, rst;
    
    // TIck FSM Connections
    logic tick_ena;
`   logic [3:0] tick;
`   
    logic [8:0] IR;

    tick_FSM tick_FSM_inst(
        .clk(clk),
        .rst(rst),
        .ena(tick_ena),
        .tick(tick)
    );

    always_ff @( posedge clk ) begin : control_unit
        case (tick)
            3'b0001 : begin
                
            end 
            3'b0010: begin
                
            end 
            3'b0100: begin
                
            end
            3'b1000: begin
                
            end
        endcase    
    end

endmodule;