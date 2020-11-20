function [v_2_c] = V_2_Ck(H_full, Ck)
%Prend en entree la matrice de parite et un noeud de variable
% retourne les Vk connecte à ce noeurd de parité Ck choisis
% ON PREND 0 1st INDICE
% [ nb_Ck, nb_Vk ] = size(H_full);
   
v_2_c=find(H_full(Ck+1,:)==1); %tu regarde les indices des 1 de la ligne i

v_2_c = v_2_c-1;

end