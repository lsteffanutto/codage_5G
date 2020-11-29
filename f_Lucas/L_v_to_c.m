function [res_L_v_to_c] = L_v_to_c( canal_obs, H_full, c_to_v, indice_V,indice_C_final)
% donne LLR d'un V qui arrive sur un C
c_to_v(isnan(c_to_v)==1)=0;

indices_des_co = C_2_Vk(H_full, indice_V); %On cherche les indices des V_k connectés à C

element_a_pas_prendre = find(indices_des_co==indice_C_final);   %On repere l'indice du C final
indices_des_co(element_a_pas_prendre) = [];                     %On l'enlève des infos des LLR à sommer

nb_v_voisins_info = length(indices_des_co); % nombre de noeud qui vont envoyer l'info

indice_V = indice_V +1; %indice 0 => 1 matrix
indices_des_co=indices_des_co+1;
sum_LLR = 0;
for i = 1:nb_v_voisins_info+1 % On parcourt les noeuds de variables reliés à c + observation du canal
    
    i;
    indice_V;
    
%     indices_des_co(i)
    
    if i == nb_v_voisins_info+1    % LLR observation du canal (on la somme en dernier)
        canal_obs;
        sum_LLR = sum_LLR + canal_obs;
        
        if isnan(sum_LLR)*1==1   %GERE LE CAS NAN
            sum_LLR=0;
        end
        
    else
        indices_des_co(i);
        L = c_to_v(indices_des_co(i),indice_V);
        sum_LLR = sum_LLR + L; % LLR info des Ck
        
        if isnan(sum_LLR)*1==1  %GERE LE CAS NAN
            sum_LLR=0;
        end
        
    end
    
end

res_L_v_to_c = sum_LLR;




end

