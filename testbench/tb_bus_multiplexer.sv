`timescale 1ns/1ns

class random_16bit_gen;
    rand bit [15:0] data;
    function display();
        $display("Mydata : %5d", data);
    endfunction
endclass

module tb_bus_multiplexer();

    bit [15:0] mux_in [9:0];
    bit [3:0] rand_sel;
    bit [15:0] multiplex_out;

    random_16bit_gen rand_16;

    initial begin
        mux_in = '{default : '0};
        rand_sel = '0;
        #1;

        repeat(20) begin
            assert(rand_16.randomize());
            void '(rand_16.display());
            // randomize(mux_in);
            // randomize(rand_sel);
            // $$display("Mux In: %5d Rand Sel: %2d");
            // #1;
        end
        $finish;
    end

endmodule