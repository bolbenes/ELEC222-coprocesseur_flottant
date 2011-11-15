module float_pack_tb ;

   import float_pack::*;
   `include "../find_first_bit_one.sv"
   
   

   // variable de conversion
   shortreal A;
   shortreal result_real;
   float_ieee B;
   float A_f;
   float_ieee B_f;
   float result_f;

   // variables de test pour la multiplication
   float A_mf, B_mf,result_mf,res_m ;
   shortreal error;

   // variables de test pour le premier un
   logic[23:0] mantisse_to_check;
   logic[4:0] result_first_one;
   int 	      i, found, position;
   
   FIND_FIRST_BIT_ONE I_FFBO (.word(mantisse_to_check), .first_one(result_first_one));
   
   initial
     begin
	#5;
	
	A = 2.5;
	B = real2float_ieee(A);
	result_real = float_ieee2real(B);
	
	//test conversion

	//$display ("resultat ieee real ieee %f  %f \n",B,result_ieee);	
	assert (A == result_real)
 	  $display ("OK resultat real-> ieee-> real\n%b\n%b\n%b\n",A,B,result_real);
	   else
	     $display ("ERROR resultat real-> ieee-> real\n%b\n%b\n%b\n",A,B,result_real);
	#5;
	A_f = $random();
	B_f = float2float_ieee(A_f);
	result_f = float_ieee2float(B_f);
	
	assert (A == result_real)
 	  $display ("OK resultat real-> ieee-> real\n%b\n%b\n%b\n",A,B,result_real);
	   else
	     $display ("ERROR resultat real-> ieee-> real\n%b\n%b\n%b\n",A,B,result_real);

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
	  end // repeat (100)



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
   
endmodule
