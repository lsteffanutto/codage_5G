function [test_syndrome]=syndrome(v_to_c,H)
%retourne 0 si syndrome OK et 1 sinon

[ligne,colonne]=size(H);

x=zeros(1,colonne); %on range tous les v dans un vecteur

for i=1:colonne
    
    index_v_i_diff_0=find(v_to_c(:,i)~=0) ; %On cherche la valeur de chaque v_i (=un des element non nul d'une colonne)  qu'on va stocker dans x
    
    x(i)=v_to_c(index_v_i_diff_0(1),i);
    
end
potentiel_mot=(x<0)*1;
valeur_syndrome=mod(potentiel_mot*H',2);
test_syndrome = any(valeur_syndrome)*1;

end

