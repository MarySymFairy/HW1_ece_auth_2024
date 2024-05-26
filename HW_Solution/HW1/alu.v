module alu
    // Declaring inputs & outputs
    (output reg zero, //1bit
    output reg [31:0] result, //32bit
    input wire [31:0] op1, //32bit
    input wire [31:0] op2, //32bit
    input wire [3:0] alu_op); //4bit
    
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


    always@(*) //κατά τον εντοπισμό αλλαγών στις εισόδους.
        begin
            case (alu_op)
                ALUOP_AND: result = op1 & op2;
                ALUOP_OR: result = op1 | op2;
                ALUOP_ADD: result = op1 + op2;
                ALUOP_SUB: result = op1 - op2;
                ALUOP_SLT: result = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0; //Προσημασμένη Σύγκριση! 
                //1 αν ειναι ισχύει η σύγκριση, 0 αν δεν ισχυει
                ALUOP_SRL: result = op1 >> op2[4:0];
                ALUOP_SLL: result = op1 << op2[4:0];
                ALUOP_SRA: result = $unsigned($signed(op1) >>> op2[4:0]);
                //η τιμή που ολισθαίνει --> μετατροπή σε προσημασμένο αριθμό  
                //το αποτέλεσμα --> μετατροπή σε μη προσημασμένο αριθμό
                ALUOP_XOR: result = op1 ^ op2;
                default: result = 32'b0; 
            endcase

            zero = (result == 32'b0) ? 1'b1 : 1'b0;
        end
             
endmodule

/*
alu_op Πράξη Αποτέλεσμα
0000 Λογική AND     op1 & op2
0001 Λογική OR      op1 | op2
0010 Πρόσθεση       op1 + op2
0110 Αφαίρεση       op1 - op2
0111 Μικρότερο από  op1 < op2 
1000 Λογική ολίσθηση δεξιά κατά op2 bits    op1 >> op2[4:0]
1001 Λογική ολίσθηση αριστερά κατά op2 bits     op1 << op2[4:0]
1010 Αριθμητική ολίσθηση δεξιά κατά op2 bits    op1 >>> op2[4:0]
1101 Λογική XOR     op1 ^ op2
*/