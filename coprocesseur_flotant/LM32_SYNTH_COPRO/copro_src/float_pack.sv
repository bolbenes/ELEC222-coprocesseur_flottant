package float_pack; 
// Ajouter ici les définition des fonctions
   // utilisée par votre coprocesseur
   parameter Nm =`TB_MANT_SIZE;
   parameter Ne = `TB_EXP_SIZE;

   logic display_debug_info = `DEBUG;
   
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
   logic signed [5:0] resultfirst1;
	
   function float float_add(input float A, input float B);
      return float_add_sub(A,B,0);
   endfunction // float_add

   function float float_sub(input A, input B);
      return float_add_sub(A,B,1);
   endfunction // float_sub
   
   
   function float float_add_sub(input float A, input float B, logic add_sub); // add: add_sub=0, sub: add_sub=1
      logic [Ne-1:0] exp_difference;
      logic [Nm+1:-2] shifted_mantisse;
      logic [Nm+1:-2] temp1, temp2; // les mantisses qu'on additionne
      logic [Nm+2:-2] result_mantisse_unnorm;
      logic [Nm:0] mantisse_to_check;
      logic [4:0] result_first_one; 
      logic [47:-2] temp_shift;
      logic [47:0] temp_mantisse;
      logic [Ne+1:0]  result_exponent;
      logic [Nm-1:0] result_mantisse;
      logic 	   result_signe;
      float Aa,Bb;
      
      logic 	   subtrahend = 0; // 0 signifie, que B est le subtrahend, 1 signifie que A est le subtrahend
      begin
	 //$display("A.sign = %b\nA.mantisse = %b\nA.exponent = %b\n",A.signe,A.mantisse,A.exponent);
	 //$display("B.sign = %b\nB.mantisse = %b\nB.exponent = %b\n",B.signe,B.mantisse,B.exponent);
	 
	 if({A.exponent,A.mantisse} <= {B.exponent,B.mantisse})
	   begin
	      Aa = B;
	      Bb = A;
	   subtrahend = 1;
	   end
	 else
	   begin
	      Aa = A;
	      Bb = B;
	   end // else: !if(A.exponent <= B.exponent)

	 if({Bb.mantisse,Bb.exponent} == '0)
	   return Aa;
	 
	 
	 if(display_debug_info)
	   $display("\nNouveau calcul\nAa.signe %b\nAa.mantisse %b\nAa.exponent %b\nBb.signe %b\nBb.mantisse %b\nBb.exponent %b",Aa.signe,Aa.mantisse,Aa.exponent,Bb.signe,Bb.mantisse,Bb.exponent);

	 exp_difference = Aa.exponent-Bb.exponent;
	 if(display_debug_info)
	   $display("\nexp_difference: %b",exp_difference);

	 if(exp_difference > Nm+2)
	   return Aa;
         temp_shift = '0;
         temp_shift[Nm] = 1;
         temp_shift[Nm-1:0]= Bb.mantisse;

	 shifted_mantisse = '0;
         shifted_mantisse[Nm:-2] = temp_shift[Nm+exp_difference-:Nm+3];
	 temp1 = {2'b01, Aa.mantisse,2'b0};
	 temp2 = shifted_mantisse;
	 
	 if(display_debug_info)
	   begin
	      $display("Aa.mantisse:\t\t\t %b",Aa.mantisse);
	      $display("shifted mantisse de Bb:\t %b",shifted_mantisse);
	      $display("mantisse de Aa:\t\t %b\n",temp1);
	   end
	 
	 
	 
	 
	 
	 
	 if(add_sub == 0) // add
	   begin
	      result_signe = Aa.signe;
	      if(Aa.signe == Bb.signe)
		begin
		   result_mantisse_unnorm = temp1+temp2;
		end
	      else
		begin
		   result_mantisse_unnorm = temp1-temp2;
		end
	   end // if (add_sub == 0)
	 else // sub
	   begin
	      if(Aa.signe == 0)
		begin
		   result_signe = subtrahend;		   
		end
	      else
		begin
		   result_signe = ~subtrahend;
		end
	      if(Aa.signe == Bb.signe)
		begin
		   result_mantisse_unnorm = temp1-temp2;
		end
	      else
		begin
		   result_mantisse_unnorm = temp1+temp2;
		end	      
	   end // else: !if(add_sub == 0)

	 resultfirst1 = find_first_bit_one({20'b0,result_mantisse_unnorm[Nm+2:2]});

	 if(display_debug_info)
	   begin
	      $display("result_mantisse_unnorm: \t%b",result_mantisse_unnorm);
	      $display("result_signe: %b",result_signe);
              $display("first 1: %d",resultfirst1);
	   end

	 if(resultfirst1 == 6'b0 && result_mantisse_unnorm[2:0] == 3'b0)
	   begin
	      Aa.mantisse = '0;
	      Aa.exponent = '0;
	      Aa.signe = result_signe;
	      return Aa;
	   end
	 else if(result_mantisse_unnorm[2]==1);
	 
	 else if(resultfirst1 == 6'b0 && result_mantisse_unnorm[2:1] == 2'b01)
	   begin
	      resultfirst1=-1;
	   end
	 else if(resultfirst1 == 6'b0 && result_mantisse_unnorm[0]==1)
	   begin
	      resultfirst1=-2;
	   end
	 result_mantisse_unnorm = result_mantisse_unnorm << (Nm+2-resultfirst1-1);
	 result_mantisse = result_mantisse_unnorm[Nm+2-:Nm];
	 result_exponent = Aa.exponent - (Nm-2-resultfirst1);
	 if(result_exponent[Ne+1] == 1 || result_exponent == '0)
	   begin
	      result_exponent = '0;
	      result_mantisse = '0;
	   end
	 else if(result_exponent[Ne:0] > 2**(Ne)-2)
	   begin
	      result_exponent = '1;
	      result_mantisse = '0;
	   end
	 
	 Aa.exponent = result_exponent;
	 
	 
         
         Aa.signe = result_signe;
         Aa.mantisse = result_mantisse;

	 if(display_debug_info)
	   begin
	      $display("result_mantisse = %b", result_mantisse);
	      $display("Aa.sign = %b\nAa.mantisse = %b\nAa.exponent = %b\n",Aa.signe,Aa.mantisse,Aa.exponent);
	   end
         return Aa;
      end
   endfunction // float_add_sub
endpackage : float_pack
   
   