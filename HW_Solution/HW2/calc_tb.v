`timescale 1ns/1ps //δήλωση χρόνου καθυστερήσεων
`include "calc.v"

module calc_tb;

    // Inputs
    reg clk;
    reg btnc, btnl, btnu, btnr, btnd;
    reg [15:0] sw;
    // Outputs
    wire [15:0] led;

    //Instantiation of calc module
    calc TB (.led(led),.clk(clk),.btnc(btnc),.btnl(btnl),.btnu(btnu),.btnr(btnr),.btnd(btnd),.sw(sw));

    initial
    begin
        clk = 1'b1;
    end
    always
    begin
        #10 clk = ~clk; //παλμός ρολογιού
    end

    initial begin 
        //Δημιουργία αρχείου vcd για να τρέξω την κυματομορφή του αρχείου
        $dumpfile("calc_tb.vcd"); //value change dump
        $dumpvars(0,calc_tb);

        btnd = 1'b1; //btnd --> enable of accumulator
        
        //Reset
        btnu = 1'b1; //btnu --> reset
        #10;
        #10 btnu = 1'b0; 
        #10;

        //OR 
        #10 btnl=1'b0; btnc=1'b1; btnr=1'b1; sw = 16'h1234;
        #10;
        
        //AND - 3'b010 & sw==16'h0ff0
        #10 btnl=1'b0; btnc=1'b1; btnr=1'b0; sw = 16'h0ff0;
        #10;

        //ADD - 3'b000 & sw==16'h324f
        #10 btnl=1'b0; btnc=1'b0; btnr=1'b0; sw = 16'h324f;
        #10;

        //SUB - 3'b001 & sw==16'h2d31
        #10 btnl=1'b0; btnc=1'b0; btnr=1'b1; sw = 16'h2d31;
        #10;

        //XOR - 3'b100 & sw==16'hffff
        #10 btnl=1'b1; btnc=1'b0; btnr=1'b0; sw = 16'hffff;
        #10;

        //Less than - 3'b101 & sw==16'h7346
        #10 btnl=1'b1; btnc=1'b0; btnr=1'b1; sw = 16'h7346;
        #10;

        //Shift Left Logical - 3'b110 & sw==16'h0004
        #10 btnl=1'b1; btnc=1'b1; btnr=1'b0; sw = 16'h0004;
        #10;

        //Shift Right Arithmetic - 3'b111 & sw==16'h0004
        #10 btnl=1'b1; btnc=1'b1; btnr=1'b1; sw = 16'h0004;
        #10;

        //Less than - 3'b101 & sw==16'hffff
        #10 btnl=1'b1; btnc=1'b0; btnr=1'b1; sw = 16'hffff;
        #10;

        #10 $finish;//πρόγραμμα προσομοίωσης πρέπει να σταματήσει
    end

endmodule

/*
Τestbench
Δημιουργήστε ένα testbench το οποίο θα ελέγχει την ορθή λειτουργία της αριθμομηχανής, καθώς
και την ορθή λειτουργία της ALU. Ελέγξτε την αριθμομηχανή με τη σειρά για τις τιμές:
-btnl, btnc, btnr (input) 
-Previous value (acc.)
-Switches (input)
-Function in ALU
-Expected Result

(btnu for reset) xxxx xxxx Reset 0x0
0,1,1 0x0 0x1234 OR 0x1234
0,1,0 0x1234 0x0ff0 AND 0x0230
0,0,0 0x0230 0x324f ADD 0X347f
0,0,1 0x347f 0x2d31 SUB 0x074e
1,0,0 0x074e 0xffff XOR 0xf8b1
1,0,1 0xf8b1 0x7346 Less Than 0x0001
1,1,0 0x0001 0x0004 Shift Left Logical 0x0010
1,1,1 0x0010 0x0004 Shift Right Arithmetic 0x0001
1,0,1 0x0001 0xffff Less Than 0x0000

*/
