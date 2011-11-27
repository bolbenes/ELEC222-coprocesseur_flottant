package float_pack;
   
   parameter Nm =`TB_MANT_SIZE;
   parameter Ne = `TB_EXP_SIZE;

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
      logic [5:0]  resultfirst1;
      logic [48:-2] temp_shift;
      logic [48:0] temp_mantisse;
      logic [Ne+1:0]  result_exponent;
      logic [Nm-1:0] result_mantisse;
      logic 	   result_signe;
      float Aa,Bb;     
      // display_debug_info = 1 -> The whole run is commented by calls of $display
      logic 	   display_debug_info;
      logic 	   subtrahend;

      exp_difference = '0;
      shifted_mantisse = '0;
      temp1 = '0;
      temp2 = '0;
      result_mantisse_unnorm = '0;
      mantisse_to_check = '0;
      resultfirst1 = '0;
      temp_shift = '0;
      temp_mantisse ='0;
      result_exponent = '0;
      result_mantisse = '0;
      result_signe = 0;
      Aa = '0;
      Bb = '0;
      
      display_debug_info = 0;
      subtrahend = 0; // 0 signifie, que B est le subtrahend, 1 signifie que A est le subtrahend
      begin
	 if({A.exponent,A.mantisse} <= {B.exponent,B.mantisse})
	   begin
	      Aa = B;
	      Bb = A;
	      subtrahend = 1; // -> si ca serait une soustraction, on voudrait calculer Bb-Aa
	   end
	 else
	   begin
	      Aa = A;
	      Bb = B;
	   end // else: !if(A.exponent <= B.exponent)


	 // Aa + 0 = Aa ...
	 if({Bb.mantisse,Bb.exponent} == '0)
	   return Aa;
	 
	 
	 if(display_debug_info)
	   $display("\nNouveau calcul\nAa.signe %b\nAa.mantisse %b\nAa.exponent %b\nBb.signe %b\nBb.mantisse %b\nBb.exponent %b",Aa.signe,Aa.mantisse,Aa.exponent,Bb.signe,Bb.mantisse,Bb.exponent);

	 
	 exp_difference = Aa.exponent-Bb.exponent;
	 
	 if(display_debug_info)
	   $display("\nexp_difference: %b",exp_difference);

	 // le nombre Bb est trop petit pour influencer le résultat
	 if(exp_difference > Nm+2)
	   begin
	      if(Aa.signe==0 && Bb.signe == 1 && Aa.mantisse == '0)
		begin
		   Aa.mantisse = '1;
		   Aa.exponent = Aa.exponent - 1;
		end
	      return Aa;
	   end
	 
         temp_shift = '0;
         temp_shift[Nm] = 1;
         temp_shift[Nm-1:0]= Bb.mantisse;

	 shifted_mantisse = '0;
         shifted_mantisse[Nm:-2] = temp_shift[Nm+exp_difference-:Nm+3];
	 temp1 = {2'b01, Aa.mantisse,2'b0};
	 temp2 = shifted_mantisse;

	 // temp1 et temp2 sont maintenant les mantisses (Bb décalé) avec plus de bits de précision
	 
	 if(display_debug_info)
	   begin
	      $display("Aa.mantisse:\t\t\t %b",Aa.mantisse);
	      $display("shifted mantisse de Bb:\t %b",shifted_mantisse);
	      $display("mantisse de Aa:\t\t %b\n",temp1);
	   end

	 // Traitemant de signe et de l'addition / de la soustraction de la mantisse
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

	 // trouver le premier un pour normaliser la mantisse du résultat
	 resultfirst1 = find_first_bit_one({20'b0,result_mantisse_unnorm[Nm+2:2]});

	 if(display_debug_info)
	   begin
	      $display("result_mantisse_unnorm: \t%b",result_mantisse_unnorm);
	      $display("result_signe: %b",result_signe);
              $display("first 1: %d",resultfirst1);
	   end

	 // Traitement des cas spéciaux avec des 1 dèrriere la précision de Nm bits
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

	 // normalisation
	 result_mantisse_unnorm = result_mantisse_unnorm << (Nm+2-resultfirst1-1);
	 result_mantisse = result_mantisse_unnorm[Nm+2-:Nm];
	 result_exponent = Aa.exponent - (Nm-2-resultfirst1);
	 // traitement des cas de saturation
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

	 // construction du résultat et return
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

   function float float_div(input float A, input float B);
      float result;
      logic signed [Ne+1:0] temp_exponent;
      logic [Nm-1:-Nm-1]    temp_mantisse;
      // display_debug_info = 1 -> The whole run is commented by calls of $display
      logic 		    display_debug_info;

      result = '0;
      temp_exponent = '0;
      temp_mantisse = '0;
      
      display_debug_info = 0;
      
      begin
	 // determination de signe
	 result.signe=A.signe^B.signe;
	 if(display_debug_info)
	   $display("\nNouveau calcul\nA.signe %b\nA.mantisse %b\nA.exponent %b\nB.signe %b\nB.mantisse %b\nB.exponent %b\n",A.signe,A.mantisse,A.exponent,B.signe,B.mantisse,B.exponent);

	 // 0 / B
	 if ({A.exponent,A.mantisse} == '0)
	   begin
              result.mantisse ='0;
              result.exponent ='0;
	      result.signe = 0;
	      return result;
 	   end
	 //division par zero
	 if (B.mantisse == 0 && B.exponent ==0)
	   begin
	      result.signe = A.signe;
	      result.mantisse ='0;
              result.exponent ='1;
	      return result;
	   end
	 
	 // calcul de l'exposant
	 temp_exponent = A.exponent - B.exponent + (2**(Ne-1)-1);
	 if(display_debug_info)
	   begin
	      $display("A.mantisse:\t%b\nB.mantisse:\t%b",{1'b1,A.mantisse},{1'b1,B.mantisse});
	      $display("temp_exponent:\t%b\n", temp_exponent);
	   end
	 // saturation
	 if(temp_exponent > 2**Ne-2)
	   begin
	      result.mantisse = '1;
	      result.exponent = 2**Ne-2;
	      return result;
	   end

	 // underflow (-> 0)
	 if(temp_exponent[Ne+1] == 1 || temp_exponent == '0)
	   begin
	      result.mantisse = '0;
	      result.exponent = '0;
	      return result;
	   end
	 
	 // calcul de la mantisse
	 temp_mantisse = {1'b1,A.mantisse,{Nm+1{1'b0}}} / {1'b1,B.mantisse};
	  if(display_debug_info)
	    begin
	       $display("temp_mantisse: %b",temp_mantisse);
	    end
	 if(temp_mantisse[0] == 1)
	   begin
	      result.mantisse = temp_mantisse[-1:-Nm];
	      result.exponent = temp_exponent;
	      return result;
	   end
	 result.mantisse = temp_mantisse[-1:-Nm-1];
	 result.exponent = temp_exponent - 1;
	 if(result.exponent == '0)
	   begin
	      result.mantisse = '0;
	      result.exponent = '0;
	      return result;
	   end
	 
	 return result;
      end
   endfunction // float_div
   
endpackage : float_pack
   
   