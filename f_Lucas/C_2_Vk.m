function [c_2_v] = C_2_Vk(H_full, Vk)
%Prend en entree la matrice de parite et un noeud de variable
% retourne les Ck connecte à ce noeurd de variables Vk
% ON PREND 0 1st INDICE
% [ nb_Ck, nb_Vk ] = size(H_full);
   
c_2_v=find(H_full(:,Vk+1)==1)'; %tu regarde les indices des 1 de la ligne i

c_2_v = c_2_v-1;

end

