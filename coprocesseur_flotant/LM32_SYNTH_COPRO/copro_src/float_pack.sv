package float_pack; 
// Ajouter ici les définition des fonctions
   // utilisée par votre coprocesseur
   parameter Nm =23;//=`TB_MANT_SIZE;
   parameter Ne = 8;//`TB_EXP_SIZE;
   
   typedef struct packed 
		  {
		     logic signe;
		     logic [Ne-1:0] exponent;
		     logic [Nm-1:0] mantisse;
		  } float ;
   
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
    
endpackage : float_pack
   