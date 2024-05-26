/*αρχείο καταχωρητών
Σχεδόν όλες οι εντολές διαβάζουν ή/και γράφουν στο αρχείο καταχωρητών.
*/
module regfile
    (input clk, 
    input write, //1bit -- Σήμα ελέγχου που υποδεικνύει εγγραφή
    input [4:0] readReg1, readReg2, //-- Διεύθυνση για τη θύρα ανάγνωσης 1 & 2
    input [4:0] writeReg, // -- Διεύθυνση για θύρα εγγραφής
    input [31:0] writeData, //32bit -- Δεδομένα προς εγγραφή
    output reg [31:0] readData1, readData2); //32bit -- Δεδομένα ανάγνωσης από τη θύρα 1 & 2
    
    //32×32-bit αρχείο καταχωρητών
    reg [31:0] registers [0:31]; //array of 32 registers, 32 bit vectors
    integer i;

//Αρχικοποιήστε τους 32 καταχωρητές με μηδενικά μέσω ενός initial block και μιας for.
    initial begin // Initialize Registers 32x32bit
        for (i=0; i<32; i=i+1) 
            registers[i] = 32'b0;
    end
    
    always @(posedge clk) 
    begin
        //Διαβάστε τις τιμές των καταχωρητών ΓΙΑ κάθε έξοδο (readData1, readData2) 
        readData1 <= registers[readReg1];
        readData2 <= registers[readReg2];

        // εγγράψτε τα δεδομένα από το writeData στην αντίστοιχη διεύθυνση που έχετε ως είσοδο.
        if (write) 
        begin 
            registers[writeReg] <= writeData;
        
        // Προσέξτε την περίπτωση που η διεύθυνση εγγραφής == με κάποια από τις διευθύνσεις ανάγνωσης.

            if (writeReg == readReg1) //readReg1 --> Διεύθυνση για τη θύρα ανάγνωσης 1
                readData1 <= writeData;
                //readData1 --> Δεδομένα ανάγνωσης από τη θύρα 1 
            if (writeReg == readReg2) 
                readData2  <= writeData;
        end
    end
endmodule
/* 
Ύστερα μέσω ενός always block διαβάστε τις τιμές των καταχωρητών από κάθε έξοδο (readData1, readData2) 
και ανάλογα με το σήμα write εγγράψτε τα δεδομένα από το writeData στην αντίστοιχη διεύθυνση που έχετε ως είσοδο. 
Προσέξτε την περίπτωση που η διεύθυνση εγγραφής είναι ίδια με κάποια από τις διευθύνσεις ανάγνωσης. */

/* 
clk Είσοδος 1 Ρολόι
readReg1 Είσοδος 5 Διεύθυνση για τη θύρα ανάγνωσης 1
readReg2 Είσοδος 5 Διεύθυνση για τη θύρα ανάγνωσης 2
writeReg Είσοδος 5 Διεύθυνση για θύρα εγγραφής
writeData Είσοδος 32 Δεδομένα προς εγγραφή
write Είσοδος 1 Σήμα ελέγχου που υποδεικνύει εγγραφή
readData1 Έξοδος 32 Δεδομένα ανάγνωσης από τη θύρα 1
readData2 Έξοδος 32 Δεδομένα ανάγνωσης από τη θύρα 2
*/