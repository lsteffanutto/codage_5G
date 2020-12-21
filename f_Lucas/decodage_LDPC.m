function [msg_recu_apres_decodage_tab, res_final_tab] = decodage_LDPC(H,canal_obs,nb_iterations,MIN_SUM,critere_arret)
% condition d'arrêt: après chaque itération, on actualise les Vi et on
% calcul => vH^T pour voir si toutes les équations de parités sont
% vérifiées. si c'est le cas on s'arrête
nombre_iteration_final_critere_arret=nb_iterations;
iterations=0;
if nb_iterations>1
    iterations=1;
end

N=length(canal_obs);

msg_tot=canal_obs;

[h, g] = ldpc_h2g(H); % g = matrice genereatrice
H_full = full(H);
[m, n] = size(H_full);
nb_v=n;
nb_c=m;
v_to_c = zeros(m,n); % INIT = LLR c_to_v=0
c_to_v = zeros(m,n);

nb_paquet_a_decode=N/n;

msg_a_decode_paquet_colloned=reshape(msg_tot,n,nb_paquet_a_decode);

res_final_tab=zeros(m,nb_paquet_a_decode);
msg_recu_apres_decodage_tab=res_final_tab;

% Et là on décode toutes les colonnes une par une
for num_paquet =1:nb_paquet_a_decode

    
v_to_c = zeros(m,n); % INIT = LLR c_to_v=0
c_to_v = zeros(m,n);



canal_obs=msg_a_decode_paquet_colloned(:,num_paquet);
 
%%%%%%%%%%%%%%% INIT / CANAL OBSERVATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

for i = 1:nb_v % On init le decodeur avec les observations ducanal
    
    v_tmp=i; %le numero du v                      
    v_obs=canal_obs(v_tmp); %observation d'un v    
    
    nb_aretes_V_vers_Ci=sum(H_full(:,v_tmp)); %combien d'arêtes à le V concerné
    
    C_avec_lesquels_ils_sont_link=find(H_full(:,v_tmp)==1); %On cherche avec quels C ils sont liés
    %vecteur avec les indexs des lignes et donc ceux des C auxqueles v est
    %lié
    
    for j =1:nb_aretes_V_vers_Ci %pour chaque C on se prepare à lui envoyer ce qu'on a observer du v
        
        c_tmp=C_avec_lesquels_ils_sont_link(j); %numéro du c
        
        [v_to_c] = update_v_to_c(v_to_c, v_obs, v_tmp-1, c_tmp-1); %MAJ v concerné vers ses c
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%On calcul ce qu'on reçoit sur les c et qu'on renvoie vers les V 1ère iteration
%L_c_to_v(H_full, v_to_c, indice_C,indice_V_final,MIN_SUM_ou_BP,critere_arret_ou_non)
%[c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, indice_c, indice_v_final)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for c_tmp2 =1:nb_c
    
    H_full_c=H_full';
    nb_aretes_C_vers_Vi=sum(H_full_c(:,c_tmp2)); %combien d'arêtes à le C concerné
    
    V_avec_lesquels_ils_sont_link=find(H_full_c(:,c_tmp2)==1); %On cherche avec quels V ils sont liés
    %vecteur avec les indexs des lignes et donc ceux des C auxqueles v est
    %lié
    for k =1:nb_aretes_C_vers_Vi
        
        v_tmp2=V_avec_lesquels_ils_sont_link(k); %numéro du v
        
        [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, c_tmp2-1,v_tmp2-1,MIN_SUM); %Co (reçoit v0 et v2 mais renvoie juste le v2) to V0
        [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, c_tmp2-1,v_tmp2-1);
    
    end
    
end

%On s'arrête et on regarde les valeurs finales sur les noeuds de variables
%V, en sommant juste ce qu'on reçoit des noeuds de parités C 
res=sum(c_to_v')'+canal_obs; %ligne magique de fin (+ observation du canal)
% on voit bien que la valeurs des V a changé après une itération en
% creusant l'écart pour la décision, yes!

%On remets a jour les V
for i = 1:nb_v % On init le decodeur avec les observations ducanal
    
    v_tmp=i; %le numero du v
    v_obs=res(v_tmp); % resultat d'un v
    
    nb_aretes_V_vers_Ci=sum(H_full(:,v_tmp)); %combien d'arêtes à le V concerné
    
    C_avec_lesquels_ils_sont_link=find(H_full(:,v_tmp)==1); %On cherche avec quels C ils sont liés
    %vecteur avec les indexs des lignes et donc ceux des C auxqueles v est
    %lié
    
    for j =1:nb_aretes_V_vers_Ci %pour chaque C on se prepare à lui envoyer ce qu'on a observer du v
        
        c_tmp=C_avec_lesquels_ils_sont_link(j); %numéro du c
        
        [v_to_c] = update_v_to_c(v_to_c, v_obs, v_tmp-1, c_tmp-1); %MAJ v concerné vers ses c
        
    end
    
end
%après la 1ère iteration on test le critere d'arret si il est active
%DABORD ON ESTIME LE DECODAGE PUIS ENSUITE ON TEST LA PARITE (LIGNE TEST
%PARITE)
if critere_arret == 1
    test_syndrome=syndrome(v_to_c,H_full); %On regarde si toutes les équation de parités sont vérifiés xH^T=0
    if test_syndrome==0
        nombre_iteration_final_critere_arret=1; %on enregistre le nb_iterations realisé au final
    end
end





%on les fait pas si critere arrêt vérifié
if nombre_iteration_final_critere_arret==1
%%%%%%%%%%%%%%%%%%AUTRES ITERATIONS%%%%%%%%%%%%%%%%%%%

if iterations ==1
    
    for i = 2:nb_iterations
        i;
        c_to_v(isnan(c_to_v)==1)=0;
        v_to_c(isnan(v_to_c)==1)=0;

%         c_to_v(c_to_v==-Inf) = -1;
%         c_to_v(c_to_v==Inf) = 1;
%         
%         v_to_c(v_to_c==-Inf) = -1;
%         v_to_c(v_to_c==Inf) = 1;
%         
        %On calcul ce qu'on reçoit sur les c
        for c_tmp2 =1:nb_c
    
            H_full_c=H_full';
            nb_aretes_C_vers_Vi=sum(H_full_c(:,c_tmp2)); %combien d'arêtes à le C concerné

            V_avec_lesquels_ils_sont_link=find(H_full_c(:,c_tmp2)==1); %On cherche avec quels V ils sont liés
            %vecteur avec les indexs des lignes et donc ceux des C auxqueles v est
            %lié
            for k =1:nb_aretes_C_vers_Vi

                v_tmp2=V_avec_lesquels_ils_sont_link(k); %numéro du v

                [res_L_c_to_v] = L_c_to_v(H_full, v_to_c, c_tmp2-1,v_tmp2-1,MIN_SUM); %Co (reçoit v0 et v2 mais renvoie juste le v2) to V0
                [c_to_v] = update_c_to_v(c_to_v, res_L_c_to_v, c_tmp2-1,v_tmp2-1);

            end
        end
        
        
        res=sum(c_to_v')'+canal_obs; %ligne magique de fin
    
        
        %On remets a jour les V
        for v_num = 1:nb_v % On init le decodeur avec les observations ducanal
    
            v_tmp=v_num; %le numero du v
            v_obs=res(v_tmp); % resultat d'un v

            nb_aretes_V_vers_Ci=sum(H_full(:,v_tmp)); %combien d'arêtes à le V concerné

            C_avec_lesquels_ils_sont_link=find(H_full(:,v_tmp)==1); %On cherche avec quels C ils sont liés
            %vecteur avec les indexs des lignes et donc ceux des C auxqueles v est
            %lié

            for j =1:nb_aretes_V_vers_Ci %pour chaque C on se prepare à lui envoyer ce qu'on a observer du v

                c_tmp=C_avec_lesquels_ils_sont_link(j); %numéro du c

                [v_to_c] = update_v_to_c(v_to_c, v_obs, v_tmp-1, c_tmp-1); %MAJ v concerné vers ses c

            end
        end
        
        %A LA FIN DE CHAQUE ITERATION ON TEST LE CRITERE D'ARRET
        if critere_arret == 1; 
            test_syndrome=syndrome(v_to_c,H_full); %On regarde si toutes les équation de parités sont vérifiés xH^T=0
            if test_syndrome==0
                nombre_iteration_final_critere_arret=i; %so on fait moins d'otérations que prévu on enregistre cenombre
                i=nb_iterations; %on met le compteur à la fin comme ça il va s'arrêter direct et fin du decodage
                break;
            end
        end
        
        
    end
        
end %FIN AUTRES ITERATIONS

end %si on fait que 1 iteration avec critere arrêt et pas les autres

test_parite=(res'<0)*1;
res=res';

% res_final = res(1:m);
res_final = res(n-m+1:n); %On prend seulement les 3 derniers bits car Id dans matrice génératrice est sur les 3 derniers bits

msg_decod=(res_final<0);
msg_decod=msg_decod*1; %passe vecteur non logical

% verification = mod(mot_de_code * H_full',2) %verif si c'est un bien un mot de code
parite=mod(test_parite * H_full',2); %verifie si le mot decodé est bien un mot de code
verif_decodage=0;
if sum(parite)==0 %si full 0 => OK
    verif_decodage=1;
end

msg_recu_apres_decodage=msg_decod;
verif_decodage; % a ne pas regarde si on mets du bruit

res_final_tab(:,num_paquet)=res_final;
msg_recu_apres_decodage_tab(:,num_paquet)=msg_recu_apres_decodage;


end

% A la fin on remet tout en colonne
res_final_tab=res_final_tab(:);
msg_recu_apres_decodage_tab=msg_recu_apres_decodage_tab(:);

nb_iterations_totales_prevues=nb_iterations;   % <=== DECOMENTE ICI POUR VOIR NB ITERATION PREVUES ET FINALE
nombre_iteration_final_critere_arret;
end
