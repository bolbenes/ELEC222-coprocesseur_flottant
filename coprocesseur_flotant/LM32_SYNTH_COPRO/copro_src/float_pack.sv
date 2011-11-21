package float_pack; 
// Ajouter ici les définition des fonctions
   // utilisée par votre coprocesseur
   parameter Nm =23;//=`TB_MANT_SIZE;
   parameter Ne = 8;//`TB_EXP_SIZE;
   `include "../find_first_bit_one.sv"
   typedef struct packed 
		  {
		     logic signe;
		     logic [Ne-1:0] exponent;
		     logic [Nm-1:0] mantisse;
		  } float;
   
   typedef struct packed 
		  {
		     logic signe;
		     logic [8-1:0] exponent;
		     logic [23-1:0]  mantisse;
		  } float_ieee;

   function float_ieee real2float_ieee ( input shortreal real_in);
	 return ($shortrealtobits(real_in));
   endfunction // real2float_ieee
   
   function shortreal float_ieee2real ( input float_ieee float_in);
      return ($bitstoshortreal(float_in));
   endfunction // float_ieee2real

   function float real2float (input shortreal real_in);
	return (float_ieee2float($shortrealtobits(real_in)));
   endfunction // real2float

   function shortreal float2real (input float float_in);
     return $bitstoshortreal(float2float_ieee(float_in));
   endfunction // float2real
   

   // condition: float: moins de bits que float_ieee
   function float_ieee float2float_ieee(input float float_in);
      
      float_ieee result;
      
     begin
	result.exponent = float_in.exponent+127-(2**(Ne-1)-1);
	result.mantisse = '0;
	result.mantisse[22:22-(Nm-1)] = float_in.mantisse;
	result.signe = float_in.signe;
	return result;
     end
   endfunction // float2float_ieee

   function float float_ieee2float(input float_ieee float_in);
      
      integer exposant;
      float result;
      
      begin
	 exposant = float_in.exponent - 127;
	 if(exposant <= 2**(Ne-1)-1 && exposant >= -2**(Ne-1)+2)
	   begin
	      result.exponent = exposant + 2**(Ne-1)-1;
	      result.mantisse = float_in.mantisse[22:22-(Nm-1)];
	   end
	 else if(exposant > 2**(Ne-1)-1)
	   begin
	      result.exponent = 2**Ne-2;
	      result.mantisse = '1;
	   end
	 else if(exposant < -2**(Ne-1)+2)
	   begin
	      result.exponent = '0;
	      result.mantisse = '0;
	   end
	 result.signe = float_in.signe;
	 return result;
      end
   endfunction // float_ieee2float
   
   function float float_mul(input float A, input float B);
      
      float result,max_exposant,min_exposant;
      logic [Nm:0] mantisse_max, mantisse_min;
      logic [2*Nm:0] mantisse_result;
            
      begin
	 // on calcule le signe
	 result.signe = A.signe + B.signe;
	 // on calcule l'exposant
	 result.exponent = A.exponent + B.exponent + (2**(Ne-1)-1);
	 //calcul de la mantisse
	 if (A.exponent < B.exponent)
	   begin
	      mantisse_max = {1,B.mantisse};
	      mantisse_min ={1,A.mantisse};
	      mantisse_result = mantisse_max * (mantisse_min >> (A.exponent - B.exponent));// on décale la mantisse de l'écart entre les exposants
	   end
	 else
	   begin
	      mantisse_max = {1,A.mantisse};
	      mantisse_min ={1,B.mantisse};
	      mantisse_result = mantisse_max * (mantisse_min >> (A.exponent - B.exponent));// on décale la mantisse de l'écart entre les exposants
	   end // else: !if(A.exponent < B.exponent)
	 if (mantisse_result*2**(-2*Nm)>=2)
	   begin
	      result.exponent = result.exponent +1;
	      result.mantisse = (mantisse_result[2*Nm-1:Nm-1]>>1);
	   end
	 else
	   result.mantisse = mantisse_result[2*Nm-1:Nm-1];
	 
	 return result; 
      end
   endfunction
   
   logic[23:0] findfirst1;
   logic [4:0] resultfirst1;
  
   function float float_add_sub(input float A, input float B, logic add_sub); // add: add_sub=0, sub: add_sub=1
   int exp_difference;
   logic[24:0] shifted_mantisse;
   logic[24:0] temp1, temp2; //(pour assigner le signe avant l'opération)
   logic[24:0] result_mantisse_unnorm;
   logic[23:0] mantisse_to_check;
   logic [4:0] result_first_one; 
   logic [63:0] temp_shift;
   logic [47:0] temp_mantisse;
   logic [23:0] result_mantisse;
   logic 	result_signe;
      
    
   float Aa,Bb;
   logic subtrahend = 0; // 0 signifie, que B est le subtrahend, 1 signifie que A est le subtrahend
   begin
	if(A.exponent <= B.exponent)
	begin
		Aa = B;
		Bb = A;
		subtrahend = 1;
	end
	else
	begin
		Aa = A;
		Bb = B;
	end
	exp_difference = Aa.exponent-Bb.exponent;
	if(exp_difference > Nm-1)
		return Aa;
        temp_shift = '0;
        temp_shift[23] = 1;
        temp_shift[22:0]= Bb.mantisse;
            
        shifted_mantisse = temp_shift[23+exp_difference-:24];
      
	if(Aa.signe == 0)
		temp1 = {2'b00, Aa.mantisse};
	else
		temp1 = {2'b11, 0-Aa.mantisse};
	if(Bb.signe == 0)
		temp2 = shifted_mantisse;
	else
		temp2 = 0-shifted_mantisse;
	if(add_sub == 0) // add
		result_mantisse_unnorm = temp1+temp2;
	else
	begin
	     if(temp1>temp2)
	       begin  
		if(subtrahend == 0)
		  begin
		     result_mantisse_unnorm = temp1-temp2;
		     result_signe = 0;
		  end
		else
		  begin
		     result_mantisse_unnorm = temp2-temp1;
		     result_signe = 1;
		  end
	       end
	     else
	       begin
		  if(subtrahend == 0)
		    begin
		       result_mantisse_unnorm = temp1-temp2;
		       result_signe = 1;
		    end
		  else
		    begin
		       result_mantisse_unnorm = temp2-temp1;
		       result_signe = 0;
		    end
	       end // else: !if(temp1>temp2)
	end // else: !if(add_sub == 0)
	resultfirst1 = find_first_bit_one(result_mantisse_unnorm);
        temp_mantisse = '0;
        temp_mantisse[47:24]=result_mantisse;
        result_mantisse = '0;
        
        result_mantisse = temp_mantisse[(47-(24-resultfirst1))-:24];
        Aa.exponent = Aa.exponent - (24-resultfirst1);
        Aa.signe = result_signe;
        Aa.mantisse = result_mantisse;
        return Aa;
   end
endfunction
endpackage : float_pack
   
