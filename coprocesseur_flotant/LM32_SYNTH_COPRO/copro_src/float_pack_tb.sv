module float_pack_tb ; 

   import float_pack::*;
   
   // variables de test pour la multiplication
   float A_mf, B_mf,result_mf,res_m ;
   shortreal error;

   // variables de test pour le premier un
   logic[23:0] mantisse_to_check;
   logic[4:0] result_first_one;
   int 	      i, found, position;

   
   
   initial
     begin
	//test multiplication
	#5;
	repeat(10)
	  begin
	     #1;
	     A_mf = real2float($random());
	     B_mf = real2float($random());
	     result_mf = float_mul(A_mf,B_mf);
	     res_m =real2float(float2real(A_mf)*float2real(B_mf));
	     error = float2real((res_m-result_mf)/(res_m+result_mf));
	     
	     if(error<0.05 && error>-0.05)
	       $display ("OK resultat correct\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	     else
	       $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	  end // repeat (10)
	     // cas particuliers
	#1;
	A_mf = real2float(0);
	B_mf = real2float(0);
	result_mf = float_mul(A_mf,B_mf);
	res_m =real2float(float2real(A_mf)*float2real(B_mf));
	error = float2real((res_m-result_mf)/(res_m+result_mf));
	
	if(error<0.05 && error>-0.05)
	  $display ("OK resultat correct\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	else
	  $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	#1;
	A_mf = real2float(10.5);
	B_mf = real2float(0);
	result_mf = float_mul(A_mf,B_mf);
	res_m =real2float(float2real(A_mf)*float2real(B_mf));
	error = float2real((res_m-result_mf)/(res_m+result_mf));
	
	if(error<0.05 && error>-0.05)
	  $display ("OK resultat correct\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	else
	  $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	#1;
	A_mf = real2float(3.25);
	B_mf = real2float(4);
	result_mf = float_mul(A_mf,B_mf);
	res_m =real2float(float2real(A_mf)*float2real(B_mf));
	error = float2real((res_m-result_mf)/(res_m+result_mf));
	
	if(error<0.05 && error>-0.05)
	  $display ("OK resultat correct\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	else
	  $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);

	A_mf = real2float(-4.553223e-02);
	B_mf = real2float(6.400000e+01);
	result_mf = float_add_sub(A_mf,B_mf,0);
	res_m =real2float(float2real(A_mf)+float2real(B_mf));
	error = float2real((res_m-result_mf)/(res_m+result_mf));
	
	if(error<0.05 && error>-0.05)
	  $display ("OK resultat correct\nA:\t\t %b\nB:\t\t %b\nA+B:\t\t %b\nA+B correct: \t %b\n Error: %f\n",A_mf,B_mf,result_mf,res_m,error);
	else
	  $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);

	
	
     end
	
   /*
		//test find first one
	
	#5;
	repeat(100)
	  begin
	     #1;
	     mantisse_to_check = $random();
		 found = 0;
		 i=23;
		 position=0;
		 while(found==0)
		 begin
			if(mantisse_to_check[i] == 1)
			begin
				found =1;
				position=i;
			end
			i--;
		 end
	  	 
	     #1;
	     if(result_first_one == position)
	       $display ("OK resultat correct");
	     else
	       $display ("ERREUR resultat incorrect\nnumber: %b\n proposed first one: %b\nreal first one: %b\n",mantisse_to_check,result_first_one,position);	
	  end // repeat (100)
     end
    */
   
endmodule
