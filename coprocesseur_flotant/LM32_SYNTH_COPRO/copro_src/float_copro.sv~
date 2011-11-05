// Squelette du coprocesseur flottant
module float_copro(
               input logic clk,
               input logic copro_valid,
               input logic copro_accept,
               input logic [10:0] copro_opcode,
               input logic [31:0] copro_op0,
               input logic [31:0] copro_op1,
               output logic copro_complete, 
               output logic[31:0] copro_result
               );

   //registres des opérandes
   logic [31:0]               op0;
   logic [31:0]               op1;
   logic [31:0]               resultat;

   //opération a réaliser
   logic [10:0]               opcode;

   //le datapath
   float_copro_dp datapath(opcode,op0,op1,resultat);
   
   //////////////////////////////////////////////////
   // Compléter en rajoutant registres et contrôle //
   //////////////////////////////////////////////////
   
endmodule

