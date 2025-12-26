`timescale 1ns/1ns

class random_mux_gen;

    randc logic [15:0] data_16x10 [9:0];
    randc logic [3:0] sel;

    constraint limit_sel {
        sel <= 9;
    };
endclass

module tb_bus_multiplexer();

    logic [15:0] mux_in [9:0];
    logic [3:0] sel;
    logic [15:0] mux_out, expected_mux_out;

    bus_multiplexer uut (
        .cpu_reg(mux_in[7:0]),
        .din_extended(mux_in[8]),
        .reg_G(mux_in[9]),
        .sel(sel),
        .multiplex_out(mux_out)
    );

    initial begin
        random_mux_gen rand_mux;
        rand_mux = new();

        mux_in = '{default : '0};
        sel = '0;

        #1;

        repeat(25) begin
            assert(rand_mux.randomize());
            mux_in = rand_mux.data_16x10;
            sel = rand_mux.sel;

            expected_mux_out = mux_in[sel];
            #1; // Send the data to uut;

            if (expected_mux_out !== mux_out) begin
                $display("[ERROR] SEL : %2d | EXPECTED OUT : %5d | OUT : %5d",
                sel, expected_mux_out, mux_out);
            end
            else begin
                $display("[OK] SEL : %2d | OUT : %5d",
                sel, mux_out);
            end

            // $display("mux_in[0] : %5d | sel = %2d", mux_in[0], sel);
        end
        $finish;
    end

endmodule