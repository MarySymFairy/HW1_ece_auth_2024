`include "alu.v"
`include "decoder.v"

module calc 
    (output wire [15:0] led, //16bit LED για την έξοδο του συσσωρευτή
    input clk, btnc, btnl, btnu, btnr, btnd, //1bit 
    input [15:0] sw); //16bit Διακόπτες για την εισαγωγή δεδομένων
    
    //Internal nets
    reg [15:0] accumulator; //16bit -- reg_out of a register
    // Σήματα για σύνδεση με την ALU
    wire [31:0] alu_op1;
    wire [31:0] alu_op2;
    wire [31:0] alu_result;
    wire [3:0] alu_op;


    always @(posedge clk) //sensitivity list --> μόνο clk, το reset είναι σύγχρονο σήμα
        begin : ACCUMULATOR
            //ACCUMULATOR 16bit
            if (btnu) //reset accumulator - σύγχρονα!!
                accumulator <= 16'b0;
            else if (btnd) begin //enable --> να ενημερώνεται κάθε φορά που πατιέται το "down" (btnd)
                    accumulator <= alu_result[15:0];
                    //τα 16 χαμηλότερα bit της εξόδου "result" 32 bit της ALU.
            end   
            
        end

    // Σύνδεση των εξόδων LED με τον accumulator
    assign led = accumulator; 

    //Επέκταση προσήμων
    assign alu_op1 = { {16{accumulator[15]}} ,accumulator};
     //● 'op1' της ALU. --> σήμα 32-bit (επέκταση προσήμου) του accumulator 16-bit.     
    assign alu_op2 = { {16{sw[15]}} ,sw};
     //● 'op2' της ALU --> σήμα 32-bit (επέκταση προσήμου) των εισόδων του διακόπτη 16-bit.

    //Instantiation of Internal Modules
    decoder calc_aluop (.alu_op(alu_op) ,.btnr(btnr) ,.btnl(btnl) ,.btnc(btnc)); //παίρνω την alu_op από εδώ
    alu calc_alu(.result(alu_result) ,.op1(alu_op1) ,.op2(alu_op2) ,.alu_op(alu_op));

endmodule