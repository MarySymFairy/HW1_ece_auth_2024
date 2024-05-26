`include "datapath.v"
//`include "ram.v"
//`include "rom.v"

module multicycle
    (input clk, //clock 
    input rst, //Σύγχρονο reset
    input [31:0] instr, // Δεδομένα εντολών από τη μνήμη εντολών
    input [31:0] dReadData, //Δεδομένα προς ανάγνωση από τη μνήμη δεδομένων
    output [31:0] PC, //Program Counter
    output [31:0] dAddress, // Διεύθυνση για δεδομένα μνήμης
    output [31:0] dWriteData, // Δεδομένα προς εγγραφή στη μνήμη δεδομένων
    output reg MemRead, //Σήμα ελέγχου που υποδεικνύει ανάγνωση μνήμης
    output reg MemWrite, //Σήμα ελέγχου που υποδεικνύει εγγραφή στη μνήμη
    output [31:0] WriteBackData); //Δεδομένα που εγγράφονται σε καταχωρητές (για αποσφαλμάτωση)

//PARAMETERS -----------------------------------------------------------------------------------
    parameter [31:0] INITIAL_PC = 32'h00400000; 
        //Parameters of FSM states - one-hot αποκωδικοποιητης
    parameter [4:0] IF = 5'b00001;
    parameter [4:0] ID = 5'b00010;
    parameter [4:0] EX = 5'b00100;
    parameter [4:0] MEM = 5'b01000;
    parameter [4:0] WB = 5'b10000;
        //Parameters of Instruction Types
    parameter [6:0] OP_I = 7'b0010011; //I-type
    parameter [6:0] OP_LW = 7'b0000011; //LW
    parameter [6:0] OP_SW = 7'b0100011; //SW
    parameter [6:0] OP_BEQ = 7'b1100011; //BEQ
    parameter [6:0] OP_R = 7'b0110011; //R-type
        //Parameters of alu_op -- MUX!!!
    parameter[3:0] ALUOP_AND = 4'b0000;
    parameter[3:0] ALUOP_OR = 4'b0001;
    parameter[3:0] ALUOP_ADD = 4'b0010;
    parameter[3:0] ALUOP_SUB = 4'b0110;
    parameter[3:0] ALUOP_SLT = 4'b0111; //less than
    parameter[3:0] ALUOP_SRL = 4'b1000; //right shift
    parameter[3:0] ALUOP_SLL = 4'b1001; //left shift
    parameter[3:0] ALUOP_SRA = 4'b1010; //right arithmetic shift
    parameter[3:0] ALUOP_XOR = 4'b1101;

    //Instantiations-------------------------------------------------------------------
    //Datapath
    datapath DATAPATH(.PC(PC) ,.instr(instr) ,.dAddress(dAddress) ,.dReadData(dReadData) ,.dWriteData(dWriteData) 
                    ,.clk(clk) ,.rst(rst) ,.ALUCtrl(ALUCtrl) ,.ALUSrc(ALUSrc) ,.WriteBackData(WriteBackData) ,.MemToReg(MemToReg) 
                    ,.PCSrc(PCSrc) ,.loadPC(loadPC) ,.RegWrite(RegWrite) ,.Zero(Zero));
    //RAM & ROM
    //INSTRUCTION_MEMORY rom(.clk(clk) ,.addr(PC[8:0]) ,.dout(instr)); //Instruction Memory
    //DATA_MEMORY ram(.clk(clk) ,.we(we) ,.addr(dAddress[8:0]) ,.din(dWriteData) ,.dout(dReadData)); //Data Memory


//FSM - 5 States---------------------------------------------------------
    reg if_enable;
    reg id_enable;
    reg ex_enable;
    reg mem_enable;
    reg wb_enable;
    reg [4:0] state;
  
    always @(posedge clk) //με το clk αλλάζει
    begin // FSM Logic
        if (rst)
            state <= IF;
        else
            case(state)
                IF: state <= ID;
                ID: state <= EX;
                EX: state <= MEM;
                MEM: state <= WB;
                WB: state <= IF;
                default: state <= IF;
        endcase
    end

    always @* 
    begin // Control Signals
        if_enable = (state == IF);
        id_enable = (state == ID);
        ex_enable = (state == EX);
        mem_enable = (state == MEM);
        wb_enable = (state == WB);
    end


    //ALUCtrl----------------------------------------------------------------------------------------------------------------------
    reg [3:0] ALUCtrl; //4bit
        //instruction type
    wire [6:0] opcode; //7bit
    wire [2:0] funct3; //3bit
    wire [6:0] funct7; //7bit
    
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    always @*
    begin // ALUCtrl --> alu_op
        case(opcode)
            OP_SW: /*SW*/ ALUCtrl = ALUOP_ADD;  //SW πρόσθεση ALUOP_ADD
            OP_LW: /*LW*/ ALUCtrl = ALUOP_ADD; //LW πρόσθεση ALUOP_ADD
            OP_BEQ: /*BEQ*/ ALUCtrl = ALUOP_SUB; //BEQ αφαίρεση ALUOP_SUB
            default: 
            begin // R-type & I-type  
                case(funct3)
                    3'b000: ALUCtrl = (funct7==7'b0100000 && opcode==OP_R) ? ALUOP_SUB : ALUOP_ADD; 
                        //MUX   //SUB or ADDI/ADD
                    3'b010: ALUCtrl = ALUOP_SLT; //SLTI /SLT
                    3'b100: ALUCtrl = ALUOP_XOR; //XORI /XOR
                    3'b110: ALUCtrl = ALUOP_OR; //ORI /OR
                    3'b111: ALUCtrl = ALUOP_AND; //ANDI /AND
                    //SHAMT
                    3'b001: ALUCtrl = ALUOP_SLL; //SLLI /SLL
                    3'b101: //MUX   //funct7 --> SRLI-0000000 -- SRAI-0100000
                        ALUCtrl = (funct7 == 7'b0000000) ? ALUOP_SRL : ALUOP_SRA; // SRLI/SRL or SRAI/SRA             
                endcase
            end
        endcase
    end

//AluSrc ---------------------------------------------------------------
    reg ALUSrc; //1bit

    //Άμεσα δεδομένα απαιτούνται μόνο για τις εντολές 'load','store' και 'ALU Immediate'. 
    always @*
    begin // ALUSrc
        case(opcode)
            OP_I: ALUSrc = 1'b1;//ALU Immediate - I type
            OP_LW: ALUSrc = 1'b1;//LW - load
            OP_SW: ALUSrc = 1'b1;//SW - store
            default: ALUSrc = 1'b0;
        endcase
    end


//------MEM του FSM------------------------------------------------------------------
    // MemRead-MemWrite ---> ram.we

    always @*
    begin 
        if (mem_enable) //FOR MEM STATE
        begin
            case (opcode)
                OP_LW: begin //LW - load
                    MemRead = 1'b1; MemWrite = 1'b0;
                end
                OP_SW: begin //SW - store
                    MemRead = 1'b0; MemWrite = 1'b1;
                end
                default: begin
                    MemRead = 1'b0; MemWrite = 1'b0;
                end
            endcase
        end
        else begin //MemWrite, MemRead τίθενται µόνο κατά τη διάρκεια του σταδίου 'MEM' της µηχανής FSM.
            MemRead=1'b0; MemWrite=1'b0;
        end
    end


//---------WB του FSM---------------------------------------------------------------------
    reg RegWrite; //1bit    
    
    always @*
    begin //RegWrite(WB state)
        RegWrite = (wb_enable && ((opcode==OP_I) || (opcode==OP_LW) || (opcode==OP_R))) ? 1'b1 : 1'b0; //RegWrite 1 μόνο όταν state == WB
    end
    
    
    reg MemToReg; //1bit
    
    always @*
    begin //MemToReg
        MemToReg = (opcode==OP_LW)  ? 1'b1 : 1'b0; //δεν εξαρτάται απο το state, μόνο από την εντολή load --> LW
    end


    reg loadPC; //1bit 
    
    always @*
    begin // loadPC
        loadPC = (wb_enable) ? 1'b1 : 1'b0; //φορτώνει νέα τιμή PC πριν την IF (στην WB)
    end


    wire Branch; //1bit --> OP_BEQ από Σχήμα 6
    wire Zero; //1bit   (alu.zero)
    reg PCSrc; //1bit

    assign Branch = (opcode==OP_BEQ); //Branch ισχύει μόνο για opcode == OP_BEQ (τότε, true, παίρνει την τιμή 1)

    always @*
    begin
        if ((Branch) && (Zero==1'b1))//BEQ εντολή  (&&-->λογικό και) 
            PCSrc = 1'b1;
        else
            PCSrc = 1'b0;
    end
    /*Το σήµα 'PCSrc' πρέπει να τίθεται σε '1' όταν υπάρχουν οι ακόλουθες συνθήκες: 
        (1) η τρέχουσα εντολή είναι μια λειτουργία "BEQ" και 
        (2) το Zero είναι ίσο με '1'*/
endmodule