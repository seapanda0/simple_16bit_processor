module binary_to_7seg(
	input wire [3:0] bcd,
	output logic [6:0] display
);
	always_comb begin
		case(bcd)
			4'h0 : display = 7'b1000000;			
			4'h1 : display = 7'b1111001;
			4'h2 : display = 7'b0100100;
			4'h3 : display = 7'b0110000;
			4'h4 : display = 7'b0011001;
			4'h5 : display = 7'b0010010;
			4'h6 : display = 7'b0000010;
			4'h7 : display = 7'b1111000;
			4'h8 : display = 7'b0000000;
            4'h9 : display = 7'b0010000;
            4'hA : display = 7'b0001000;
            4'hB : display = 7'b0000011;
            4'hC : display = 7'b1000110;
            4'hD : display = 7'b0100001;
            4'hE : display = 7'b0000110;
            4'hF : display = 7'b0001110;
		endcase
	end
endmodule

module fsm_tick_to_7seg(
	input wire [3:0] fsm_tick,
	output logic [6:0] display
);
	always_comb begin
		case(fsm_tick)
			4'b0001 : display = 7'b1111001;
			4'b0010 : display = 7'b0100100;
			4'b0100 : display = 7'b0110000;
			4'b1000 : display = 7'b0011001;
            default: display = 7'b0;
		endcase
	end
endmodule
