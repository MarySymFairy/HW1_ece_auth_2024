`include "alu.v"
`include "regfile.v"

module datapath
    //Inputs
    (input clk, //clock 
    input rst, //Σύγχρονο reset
    input [31:0] instr, // Δεδομένα εντολών από τη μνήμη εντολών
    input PCSrc, // Πηγή του PC
    input ALUSrc, //Πηγή του 2ου τελεστή της ALU
    input RegWrite, //Εγγραφή δεδομένων στους καταχωρητές
    input MemToReg,  //Πολυπλέκτης εισόδου στους καταχωρητές
    input [3:0] ALUCtrl,//Δείχνει ποια λειτουργία πρέπει να εκτελέσει η ALU
    input loadPC, //Ενημέρωση του PC με μια νέα τιμή
    input [31:0] dReadData, //Δεδομένα προς ανάγνωση από τη μνήμη δεδομένων
    //Outputs
    output [31:0] dAddress, // Διεύθυνση για δεδομένα μνήμης
    output [31:0] dWriteData, // Δεδομένα προς εγγραφή στη μνήμη δεδομένων
    output reg [31:0] PC, //Program Counter
    output Zero,  //Ένδειξη μηδενισμού ALU
    output [31:0] WriteBackData); //WriteBack δεδομένα που επιστρέφουν στους καταχωρητές


    parameter [31:0] INITIAL_PC = 32'h00400000;
            //Parameters of Instruction Types
    parameter [6:0] OP_I = 7'b0010011; //I-type
    parameter [6:0] OP_LW = 7'b0000011; //LW
    parameter [6:0] OP_SW = 7'b0100011; //SW
    parameter [6:0] OP_BEQ = 7'b1100011; //BEQ
    parameter [6:0] OP_R = 7'b0110011; //R-type

    //INTERNAL NETS--------------------------------------------------------------------------------
    //Regfile
    wire [31:0] readData1;
    wire [31:0] readData2;
    reg [31:0] writeData; // ram.v ---> MUX WRITEBACK ---> regfile.writeData
    //ALU
    wire [31:0] alu_result;
    reg [31:0] alu_op2; // --> MUX ALU_OP2 ---> alu.alu_op2
    //PC
    wire [31:0] branch_offset;
    //Immune Generation
    wire [6:0] opcode;
    reg [31:0] immI, immS, immB, immLW; //επέκταση προσήμου


    //Instantiation----------------------------------------------------------------------------------
    regfile datapath__REGFILE(.clk(clk) ,.write(RegWrite) ,.readReg1(instr[19:15]), .readReg2(instr[24:20]) ,.writeReg(instr[11:7]) 
                            ,.writeData(writeData) ,.readData1(readData1) ,.readData2(readData2));
    alu datapath_ALU(.zero(Zero) ,.result(alu_result) ,.op1(readData1) ,.op2(alu_op2) , .alu_op(ALUCtrl));  

    assign dAddress = alu_result; //από Σχήμα 6 και Σχημα 7
    assign dWriteData = readData2; //από Σχήμα 7

    //MUX WRITEBACK 
    always @* 
    begin 
        writeData = (MemToReg) ? (dReadData) : dAddress ; 
    end
    
    assign WriteBackData = writeData;  //Τα δεδομένα που γράφονται στους καταχωρητές πρέπει επίσης να συνδεθούν στην έξοδο WriteBackData
    

    //MUX ALU_OP2 ---> (ALUSrc)
    always @*
    begin
        case(opcode) //από immediate Generation
            OP_I: alu_op2 = (ALUSrc) ? immI : readData2; //I-type - ALU Immediate
            OP_SW: alu_op2 = (ALUSrc) ? immS : readData2; //S-type - SW - store
            OP_LW: alu_op2 = (ALUSrc) ? immLW : readData2; //LW - load
            OP_BEQ: alu_op2 = (ALUSrc) ? immB : readData2; //B-type (BEQ) διακλάδωση
        endcase
    end      


// --------------------------------------------------------------PC----------------------------------------------------------------
    assign branch_offset = (immB << 1); //SLL  (????)

    always @(posedge clk)  //(rst είναι σύγχρονο!)
    begin //Program Counter - PC 
        if (rst)
            PC <= INITIAL_PC;
        else begin
            if (loadPC) //enable
            begin // MUX PC  --> (PSCrc)
                PC = (PCSrc) ? (PC + branch_offset) : (PC + 32'd4) ;//branch_offset μόνο για B-type(διακλαδωση) (decimal4)
            end
        end
    end

//----------------------------------------------------IMMEDIATE GENERATION---------------------------------------------------------------
    assign opcode = instr[6:0];

    always @*
    begin //Immediate Generation
        case(opcode)
            OP_I: immI = { {20{instr[31]}} , instr[31:20]}; //I-type
            OP_SW: immS = { {20{instr[31]}}, instr[31:25], instr[11:7]}; //S-type - SW
            OP_LW: immLW = { {20{instr[31]}} , instr[31:20]}; //LW
            OP_BEQ: immB = { {20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8] }; //B-type (BEQ)
        endcase
    end


endmodule

//ΛΑΘΟΣ Δεν εχω παρει την περιπτωση του R για immR, οποτε λάθος και στο ALUSrc