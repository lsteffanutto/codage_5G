function [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, indice_C,indice_V_final)
% donne LLR d'un C qui arrive sur un V
% LLR qui arrive sur noeuds de parité (sont tockés dans v_to_c);
% on fait un 2atanh(...) avec les noeuds de variables qui arrivent
% On donne les indices des noeuds co a C    => DIAPO p.49
% indice_C = indice_C +1 %indice 0 => 1 matrix
% indice_V_final = indice_V_final +1
v_to_c(isnan(v_to_c)==1)=0;

indices_des_co = V_2_Ck(H_full, indice_C); %On cherche les indices des V_k connectés à C

element_a_pas_prendre = find(indices_des_co==indice_V_final);   %On repere l'indice du V final
indices_des_co(element_a_pas_prendre) = [];                     %On l'enlève des infos des LLR à sommer

nb_v_voisins_info = length(indices_des_co); % nombre de noeud qui vont envoyer l'info

indice_C = indice_C +1;
indices_des_co=indices_des_co+1;
prod_tanh = 1;
L_tab=[];
for i = 1:nb_v_voisins_info % On parcourt les noeuds de variables reliés à c + observation du canal
    i;
    indice_C;
    indices_des_co(i);
    L = v_to_c(indice_C,indices_des_co(i));
    
    %MIN-SUM
%     L_tab = [L_tab L]; %on stock les L car à la fin on va prendre le min
%     prod_tanh = prod_tanh*sign(L); %On fait le produit de tous les L

    %BP
    prod_tanh = prod_tanh * tanh( L /2 ); % LLR info des Vk
    
end

%MIN-SUM
% res_L_c_to_v=prod_tanh*min(abs(L_tab)); % on multiplie par le min des L à la fin

%BP
% on applique la formule pour le produit des tangentes 2atanh(prod_tanh)
res_L_c_to_v = 2*atanh(prod_tanh);




end

