`timescale 1ns/1ns
`include "multicycle.v"
`include "rom.v"
`include "ram.v"
//`include "rom_bytes.data"

module multicycle_tb;
    //Inputs
    reg clk, rst;
    wire [31:0] instr;
    wire [31:0] dReadData;

    //Outputs
    wire [31:0] PC;
    wire [31:0] dAddress;
    wire [31:0] dWriteData;
    wire MemRead, MemWrite;
    wire [31:0] WriteBackData;

    //Instantiation of multicycle (top) module
    multicycle TB(.clk(clk) ,.rst(rst) ,.instr(instr) ,.dReadData(dReadData) ,.PC(PC) ,
    .dAddress(dAddress) ,.dWriteData(dWriteData) ,.MemRead(MemRead) ,.MemWrite(MemWrite) ,.WriteBackData(WriteBackData));
    
    //RAM & ROM
    INSTRUCTION_MEMORY rom(.clk(clk) ,.addr(PC[8:0]) ,.dout(instr)); //Instruction Memory
    DATA_MEMORY ram(.clk(clk) ,.we(MemWrite) ,.addr(dAddress[8:0]) ,.din(dWriteData) ,.dout(dReadData)); //Data Memory
        //we = MemWrite ---> μόνο όταν γράφω στην μνήμη το we = 1 .


    initial
    begin
        clk = 1'b1;
    end
    always
    begin
        #10 clk = ~clk; //παλμός ρολογιού
    end

    initial begin 
        $dumpfile("multicycle_tb.vcd"); //value change dump
        $dumpvars(0, multicycle_tb);

        rst = 1'b1;
        #10;
        #10 rst = 1'b0; //dReadData = 32'b0;
        #10;

        #12800 $finish;
    end
endmodule

/*Χρησιμοποιήστε τα αρχεία μνημών που σας δίνονται για τη μνήμη εντολών και για τη μνήμη
δεδομένων, καθώς και τo αρχείo με την αρχικοποίηση των εντολών (.data) και εκτελέστε
προσομοιώσεις.
*/