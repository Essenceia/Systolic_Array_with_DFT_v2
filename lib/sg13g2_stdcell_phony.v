/* Fake sg13g2 cell library used for FPGA emulation,
   hand crafter with pain and IHP documentation:
   https://github.com/IHP-GmbH/IHP-Open-PDK/blob/main/ihp-sg13g2/libs.ref/sg13g2_stdcell/doc/sg13g2_stdcell_typ_1p20V_25C.pdf

   This is not an official library! 
   It only covers the subset of the SG13G2 cells my design is using! 
   There might be bugs!
*/

// double and -> single or, output not inverted
module sg13g2_a21o_1 (
    input  wire A1,
    input  wire A2,
    input  wire B1,
    output wire X
);
    assign X = (A1 & A2) | B1;
endmodule
module sg13g2_a21o_2 (
    input  wire A1,
    input  wire A2,
    input  wire B1,
    output wire X
);
    assign X = (A1 & A2) | B1;
endmodule


// double and -> single or, output inverted
module sg13g2_a21oi_1 (
    input  wire A1,
    input  wire A2,
    input  wire B1,
    output wire Y
);
    assign Y = ~((A1 & A2) | B1);
endmodule
module sg13g2_a21oi_2 (
    input  wire A1,
    input  wire A2,
    input  wire B1,
    output wire Y
);
    assign Y = ~((A1 & A2) | B1);
endmodule

// double double and, single or, everything ored together, inverted output
module sg13g2_a221oi_1 (
    input  wire A1,
    input  wire A2,
    input  wire B1,
    input  wire B2,
    input  wire C1,
    output wire Y
);
    assign Y = ~((A1 & A2) | (B1 & B2) | C1);
endmodule

// double double and, everything ored together, inverted output
module sg13g2_a22oi_1 (
    input  wire A1,
    input  wire A2,
    input  wire B1,
    input  wire B2,
    output wire Y
);
    assign Y = ~((A1 & A2) | (B1 & B2));
endmodule

// and gate
module sg13g2_and2_1 (
    input  wire A,
    input  wire B,
    output wire X
);
    assign X = A & B;
endmodule
module sg13g2_and2_2 (
    input  wire A,
    input  wire B,
    output wire X
);
    assign X = A & B;
endmodule

// triple and gate
module sg13g2_and3_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire X
);
    assign X = A & B & C;
endmodule

// quadruple and gate
module sg13g2_and4_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    input  wire D,
    output wire X
);
    assign X = A & B & C & D;
endmodule

// buffers
module sg13g2_buf_1 (
    input  wire A,
    output wire X
);
    assign X = A;
endmodule
module sg13g2_buf_2 (
    input  wire A,
    output wire X
);
    assign X = A;
endmodule
module sg13g2_buf_4 (
    input  wire A,
    output wire X
);
    assign X = A;
endmodule
module sg13g2_buf_8 (
    input  wire A,
    output wire X
);
    assign X = A;
endmodule
module sg13g2_buf_16 (
    input  wire A,
    output wire X
);
    assign X = A;
endmodule

// decoupling capacitors, no logic
module sg13g2_decap_4 (
);
endmodule
module sg13g2_decap_8 (
);
endmodule
module sg13g2_fill_1 (
);
endmodule
module sg13g2_fill_2 (
);
endmodule

// Note: the pdk only has async reset dff's, so even if we 
// didn't put a reset an async reset dff is used
//
// posedge trigger dff with async reset on low (B = bar, polarite inverse)
module sg13g2_dfrbpq_1 (
    input  wire CLK,
    input  wire D,
    input  wire RESET_B,
    output reg  Q
);
    always @(posedge CLK or negedge RESET_B) begin
        if (!RESET_B)
            Q <= 1'b0;
        else
            Q <= D;
    end
endmodule

// scan version of the async reset on low, posedge triggered dff
module sg13g2_sdfrbpq_1 (
    input  wire CLK,
    input  wire D,
    input  wire RESET_B,
    input  wire SCE,
    input  wire SCD,
    output reg  Q
);
    always @(posedge CLK or negedge RESET_B) begin
        if (!RESET_B)
            Q <= 1'b0;
        else
            Q <= SCE ? SCD : D;
    end
endmodule
module sg13g2_sdfrbpq_2 (
    input  wire CLK,
    input  wire D,
    input  wire RESET_B,
    input  wire SCE,
    input  wire SCD,
    output reg  Q
);
    always @(posedge CLK or negedge RESET_B) begin
        if (!RESET_B)
            Q <= 1'b0;
        else
            Q <= SCE ? SCD : D;
    end
endmodule

// delay gate, help prevent hold violation, +1.5ns
module sg13g2_dlygate4sd3_1 (
    input  wire A,
    output wire X
);
    assign X = A;
endmodule

// inverter
module sg13g2_inv_1 (
    input  wire A,
    output wire Y
);
    assign Y = ~A;
endmodule
module sg13g2_inv_2 (
    input  wire A,
    output wire Y
);
    assign Y = ~A;
endmodule
module sg13g2_inv_4 (
    input  wire A,
    output wire Y
);
    assign Y = ~A;
endmodule
module sg13g2_inv_8 (
    input  wire A,
    output wire Y
);
    assign Y = ~A;
endmodule

// muxes
// 2 way
module sg13g2_mux2_1 (
    input  wire A0,
    input  wire A1,
    input  wire S,
    output wire X
);
    assign X = S ? A1 : A0;
endmodule
module sg13g2_mux2_2 (
    input  wire A0,
    input  wire A1,
    input  wire S,
    output wire X
);
    assign X = S ? A1 : A0;
endmodule
// 4 way
module sg13g2_mux4_1 (
    input  wire A0,
    input  wire A1,
    input  wire A2,
    input  wire A3,
    input  wire S0,
    input  wire S1,
    output wire X
);
    assign X = S1 ? (S0 ? A3 : A2)
                  : (S0 ? A1 : A0);
endmodule

// nands
module sg13g2_nand2_1 (
    input  wire A,
    input  wire B,
    output wire Y
);
    assign Y = ~(A & B);
endmodule
module sg13g2_nand2_2 (
    input  wire A,
    input  wire B,
    output wire Y
);
    assign Y = ~(A & B);
endmodule


module sg13g2_nand2b_1 (
    input  wire A_N,
    input  wire B,
    output wire Y
);
    assign Y = ~(~A_N & B);
endmodule
module sg13g2_nand2b_2 (
    input  wire A_N,
    input  wire B,
    output wire Y
);
    assign Y = ~(~A_N & B);
endmodule

module sg13g2_nand3_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Y
);
    assign Y = ~(A & B & C);
endmodule


module sg13g2_nand3b_1 (
    input  wire A_N,
    input  wire B,
    input  wire C,
    output wire Y
);
    assign Y = ~(~A_N & B & C);
endmodule

module sg13g2_nand4_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    input  wire D,
    output wire Y
);
    assign Y = ~(A & B & C & D);
endmodule

// nor
module sg13g2_nor2_1 (
    input  wire A,
    input  wire B,
    output wire Y
);
    assign Y = ~(A | B);
endmodule
module sg13g2_nor2_2 (
    input  wire A,
    input  wire B,
    output wire Y
);
    assign Y = ~(A | B);
endmodule


module sg13g2_nor2b_1 (
    input  wire A,
    input  wire B_N,
    output wire Y
);
    assign Y = ~(A | ~B_N);
endmodule
module sg13g2_nor2b_2 (
    input  wire A,
    input  wire B_N,
    output wire Y
);
    assign Y = ~(A | ~B_N);
endmodule


module sg13g2_nor3_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Y
);
    assign Y = ~(A | B | C);
endmodule
module sg13g2_nor3_2 (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Y
);
    assign Y = ~(A | B | C);
endmodule

module sg13g2_nor4_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    input  wire D,
    output wire Y
);
    assign Y = ~(A | B | C | D);
endmodule
module sg13g2_nor4_2 (
    input  wire A,
    input  wire B,
    input  wire C,
    input  wire D,
    output wire Y
);
    assign Y = ~(A | B | C | D);
endmodule

// double or, single and, inverted output
module sg13g2_o21ai_1 (
    input  wire A1,
    input  wire A2,
    input  wire B1,
    output wire Y
);
    assign Y = ~((A1 | A2) & B1);
endmodule

// or
module sg13g2_or2_1 (
    input  wire A,
    input  wire B,
    output wire X
);
    assign X = A | B;
endmodule
module sg13g2_or3_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire X
);
    assign X = A | B | C;
endmodule
module sg13g2_or4_1 (
    input  wire A,
    input  wire B,
    input  wire C,
    input  wire D,
    output wire X
);
    assign X = A | B | C | D;
endmodule

// tie cells, high
module sg13g2_tiehi (
    output wire L_HI
);
    assign L_HI = 1'b1;
endmodule
// low
module sg13g2_tielo (
    output wire L_LO
);
    assign L_LO = 1'b0;
endmodule

// xor
module sg13g2_xor2_1 (
    input  wire A,
    input  wire B,
    output wire X
);
    assign X = A ^ B;
endmodule
// inverted xor
module sg13g2_xnor2_1 (
    input  wire A,
    input  wire B,
    output wire Y
);
    assign Y = ~(A ^ B);
endmodule

// yay, finished
