// Squelette du coprocesseur flottant
module float_copro # (parameter cycle_add = 2, cycle_mul = 1, cycle_div = 10)  
   (
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
   logic [31:0] 	      op1;
   logic [31:0] 	      resultat;
   
   // machine à état
   enum 		      logic	      {INIT,BUSY} state, n_state;
 
   logic [4:0] 		      counter;
   
			      
   //opération a réaliser
   logic [10:0] 	      opcode;
   
   //le datapath
   float_copro_dp datapath(opcode,op0,op1,resultat);
   
   //////////////////////////////////////////////////
   // Compléter en rajoutant registres et contrôle //
   //////////////////////////////////////////////////

   assign opcode = copro_opcode;
   assign op0 = copro_op0;
   assign op1 = copro_op1;
   assign copro_result=resultat;
   
 

   
   always_comb // determination des etats
     begin
	n_state <= state ;
	
	case (state)
	  
	  INIT : if(copro_valid == 1)
	    n_state <= BUSY;
	  
	  BUSY : if (copro_accept == 1)
	    n_state <= INIT;
	  
	endcase
	  
     end // always_comb

   always_comb
     begin
	copro_complete <= 0;

	if (state == BUSY)
	  
	  case(copro_opcode)
	    
	    11'd0 :
	      if (counter >= cycle_add)
		copro_complete <= 1;
	    11'd1 :
	      if (counter >= cycle_add)
		copro_complete <= 1;
	    11'd2 :
	      if (counter >= cycle_mul)
		copro_complete <= 1;
	    11'd3 :
	      if (counter >= cycle_div)
		copro_complete <= 1;
	  endcase	
     end


   
   always_ff@(posedge clk)
     begin
	
	
	if (~copro_valid)
	  state <= INIT;
	
	else
	  begin
	     state <= n_state;
	     if (state == BUSY)
	       counter <= counter + 1;
	     else
	       counter <= 0;
	  end
     end
   
   
endmodule

