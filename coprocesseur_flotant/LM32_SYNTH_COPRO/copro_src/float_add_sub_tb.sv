module float_add_sub_tb;
   
   import float_pack::*;
   
   float A_mf,B_mf,result_mf,res_m;
   shortreal error;
   initial  
     begin
	#5;
	repeat(10)
	  begin
	     #1;
	     A_mf = real2float($random());
	     B_mf = real2float($random());
	     result_mf = float_add_sub(A_mf,B_mf,0);//test addition
	     res_m =real2float(float2real(A_mf)+float2real(B_mf));
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
	result_mf = float_add_sub(A_mf,B_mf,0);//test addition
	res_m =real2float(float2real(A_mf)+float2real(B_mf));
	error = float2real((res_m-result_mf)/(res_m+result_mf));
	
	if(error<0.05 && error>-0.05)
	  $display ("OK resultat correct\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	else
	  $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	#1;
	A_mf = real2float(10.5);
	B_mf = real2float(0);
	result_mf = float_add_sub(A_mf,B_mf,0);//test addition
	res_m =real2float(float2real(A_mf)+float2real(B_mf));
	error = float2real((res_m-result_mf)/(res_m+result_mf));
	
	if(error<0.05 && error>-0.05)
	  $display ("OK resultat correct\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	else
	  $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	#1;
	A_mf = real2float(3.25);
	B_mf = real2float(4.5);
	result_mf = float_add_sub(A_mf,B_mf,0);//test addition	
	res_m =real2float(float2real(A_mf)+float2real(B_mf));
	error = float2real((res_m-result_mf)/(res_m+result_mf));
	
	if(error<0.05 && error>-0.05)
	  $display ("OK resultat correct\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	else
	  $display ("ERREUR resultat incorrect\n%d\n%d\n%d\n%d\n%f\n",A_mf,B_mf,result_mf,res_m,error);
	//cas ou l'écart entre les exposants est supérieur à 24
	#1;
	
     end
endmodule 