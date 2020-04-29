`timescale 1ns/1ps

module misr_tb;
    parameter LFSR_LENGTH = 4;//16;
    parameter LFSR_SEED_VAL = 4'b1101;//16'b1011_0101_1101_1010;
    parameter MISR_SEED_VAL = 4'b0101;//16'b0101_0101_1101_1110;
    parameter LFSR_PRIM_POLY = 4'b1101;//16'b1011_0100_0000_0001;  // 1+x^11+x^13+x^14+x^16

    logic clk;
    logic resetn;
    logic lfsr_en;
    logic lfsr_out;
    logic [LFSR_LENGTH-1:0] misr_out_buf;
    logic [LFSR_LENGTH-1:0] lfsr_state_out;
    logic [LFSR_LENGTH-1:0] misr_state_out;
    logic misr_out;

    // clock generation
    initial begin
        clk = 0;
        forever begin
            #10ns clk = ~clk;
        end
    end

    // test block
    initial begin
        resetn = 0;
        lfsr_en = 0;

        repeat(2)
            @(posedge clk);
        resetn = 1;
        lfsr_en = 1;
    end

    // record lfsr internal states
    always @(lfsr_state_out) begin
        $display("lfsr:%0d", lfsr_state_out);
    end

    // record misr internal states
    initial begin
        $monitor("misr:%0d", misr_state_out);
    end

    // finish simulation
    initial begin
        #1000ns;
        $finish();
    end

    // Instantiation of LFSR
    lfsr #(
                // Parameters
                .LFSR_LENGTH(LFSR_LENGTH),
                .LFSR_PRIM_POLY(LFSR_PRIM_POLY),  // tap on 16 i.e. 1+x^11+x^13+x^14+x^16
                .LFSR_SEED_VAL(LFSR_SEED_VAL)
            )I_LFSR (
                // IO ports
                .lfsr_clk(clk),                     // input
                .resetn(resetn),                    // input
                .lfsr_en(lfsr_en),                  // input
                .lfsr_state_out(lfsr_state_out),    // output
                .lfsr_out(lfsr_out)                 // output
            );

    // Instantiation of DUT
    misr #(
                // Parameters
                .LFSR_LENGTH(LFSR_LENGTH),
                .LFSR_PRIM_POLY(LFSR_PRIM_POLY),  // tap on 16 i.e. 1+x^11+x^13+x^14+x^16
                .LFSR_SEED_VAL(MISR_SEED_VAL)
            )DUT (
                // IO ports
                .lfsr_clk(clk),                     // input
                .resetn(resetn),                    // input
                .misr_en(lfsr_en),                  // input
                .misr_dat_in(lfsr_state_out),       // input
                .misr_state_out(misr_state_out),    // output
                .misr_out(misr_out)                 // output
            );
endmodule