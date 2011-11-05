module float_pack_tb ;

   import float_pack::*;

   shortreal A;
   shortreal result_real;
   float_ieee B;

   float A_f;
   float_ieee B_f;
   float result_f;
      

   
   initial
     begin
	#5;
	
	A = 2.5;
	B = real2float_ieee(A);
	result_real = float_ieee2real(B);
	
	

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
          
     end
   
endmodule
