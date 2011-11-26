// ici on implémente la fonction de base pour trouver dans un bloc de 2 bits les cas '1X' et '01'.
// Le cas '00' n'est pas important, parce qu'on va choisir avec un arbre et une comparaison les blocs de base qui sont important.
function logic basic_2_tuple(input logic[1:0] tupel2);
   if(tupel2 == 2'b10 || tupel2 == 2'b11)
     begin
	return 1;
     end
   else
     begin
	return 0;
     end
endfunction // basic_2_tuple

// la fonction retourne la position du premier un, en partant avec la position 0
// p.e. 0.....010 -> la fonctin retourne 1
function logic[4:0] find_first_bit_one(input logic[23:0] word);
   logic[4:0] first_one;
   
// Calculation de la position du premier un
begin
	if(word[23:16] == '0)
	begin
		first_one[4]=0;
		if(word[15:8] == '0)
		begin
			first_one[3]=0;
			if(word[7:4] == '0)
			begin
				first_one[2]=0;
				if(word[3:2] == '0)
				begin
					first_one[1]=0;
					first_one[0]=basic_2_tuple(word[1:0]);
				end
				else
				begin
					first_one[1]=1;
					first_one[0]=basic_2_tuple(word[3:2]);
				end
			end
			else // word[7:4] != '0
			begin
				first_one[2]=1;
				if(word[7:6] == '0)
				begin
					first_one[1]=0;
					first_one[0]=basic_2_tuple(word[5:4]);
				end
				else
				begin
					first_one[1]=1;
					first_one[0]=basic_2_tuple(word[7:6]);
				end
			end
		end
		else // word[15:8] != '0
		begin
			first_one[3]=1;
			if(word[15:12] == '0)
			begin
				first_one[2]=0;
				if(word[11:10] == '0)
				begin
					first_one[1]=0;
					first_one[0]=basic_2_tuple(word[9:8]);
				end
				else
				begin
					first_one[1]=1;
					first_one[0]=basic_2_tuple(word[11:10]);
				end
			end
			else // word[15:12] != '0
			begin
				first_one[2]=1;
				if(word[15:14] == '0)
				begin
					first_one[1]=0;
					first_one[0]=basic_2_tuple(word[13:12]);
				end
				else
				begin
					first_one[1]=1;
					first_one[0]=basic_2_tuple(word[15:14]);
				end
			end
		end // word[15:8]
	end
	else // word[23:16] != '0
	begin
		first_one[4]=1;
		first_one[3]=0;
		if(word[23:20] == '0)
		begin
			first_one[2]=0;
			if(word[19:18] == '0)
			begin
				first_one[1]=0;
				first_one[0]=basic_2_tuple(word[17:16]);
			end
			else
			begin
				first_one[1]=1;
				first_one[0]=basic_2_tuple(word[19:18]);
			end
		end
		else // word[23:20] != '0
		begin
			first_one[2]=1;
			if(word[23:22] == '0)
			begin
			        first_one[1]=0;
				first_one[0]=basic_2_tuple(word[21:20]);
			end
			else
			begin
				first_one[1]=1;
				first_one[0]=basic_2_tuple(word[23:22]);
			end
		end
		
	end // else: !if(word[23:16] == '0)
   return first_one;
end
endfunction