module binary_to_7seg(
	input wire [4:0] bcd,
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
			4'hA : display = 7'b1110111;
			4'hB : display = 7'b1111100;
			4'hC : display = 7'b0111001;
			4'hD : display = 7'b1011110;
			4'hE : display = 7'b1111001;
			4'hF : display = 7'b1110001;
		endcase
	end
endmodule