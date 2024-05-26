//grammi 4 !!!

module decoder
    (output [3:0] alu_op,// reg if always block
    input btnr, btnl, btnc); //4bit
    
    //internal nets
    wire x1,x2,x3,x4;
    wire y1,y2,y3,y4;
    wire z1,z2,z3,z4;
    wire r1,r2,r3,r4;

 //gate: (output, inputs) --> STRUCTURAL VERILOG
    //alu_op[0]: 
    not(x1, btnr);
    and(x2, x1, btnl);
    xor(x3, btnl, btnc);
    and(x4, btnr, x3);
    or (alu_op[0], x2, x4);

    //alu_op[1]:
    not(y2, btnl);
    not(y3, btnc);
    and(y1, btnr, btnl);
    and(y4, y2, y3);
    or(alu_op[1], y1, y4);
        
    //alu_op[2]:  
    not(z1, btnc);
    and(z2, btnr, btnl);
    xor(z3, btnr, btnl);
    or (z4, z2, z3);
    and(alu_op[2], z1, z4);

    //alu_op[3]: 
    not(r1, btnr);
    xnor(r2, btnr, btnc);
    and(r3, r1, btnc);
    or(r4, r3, r2);
    and(alu_op[3], r4, btnl);

endmodule

/*
Το σήμα 'alu_op' καθορίζει ποια πράξη της ALU θα εκτελεστεί. Θα καθορίσετε ποια λειτουργία θα
εκτελέσετε με βάση την τιμή των τριών πλήκτρων: btnl, btnc και btnr. Θα πρέπει να
δημιουργήσετε το συνδυαστικό κύκλωμα των Σχημάτων 2-5 που να παράγει το κατάλληλο σήμα
'alu_op' με βάση την τιμή αυτών των τριών πλήκτρων. Υλοποιήστε το κύκλωμα decoder.v σε
structural verilog και συνδέστε το στο κύκλωμα αριθμομηχανής calc.v
*/